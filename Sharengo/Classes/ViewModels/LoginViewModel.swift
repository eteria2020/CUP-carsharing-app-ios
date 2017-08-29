//
//  LoginViewModel.swift
//  Sharengo
//
//  Created by Dedecube on 12/06/17.
//  Copyright © 2017 Dedecube. All rights reserved.
//

import Foundation
import RxSwift
import Boomerang
import Action
import ReachabilitySwift
import KeychainSwift
import Localize_Swift

/**
 Enum that specifies selection input
 */
public enum LoginSelectionInput: SelectionInput {
    case login
    case forgotPassword
    case register
    case continueAsNotLogged
}

/**
 Enum that specifies selection output
 */
public enum LoginSelectionOutput: SelectionOutput {
    case login
    case forgotPassword
    case register
    case continueAsNotLogged
}

/**
 The Login model provides data related to display content on login
 */
public final class LoginViewModel: ViewModelType {
    fileprivate var apiController: ApiController = ApiController()
    /// Selection variable
    public lazy var selection:Action<LoginSelectionInput,LoginSelectionOutput> = Action { input in
        switch input {
        case .login:
            return .just(.login)
        case .forgotPassword:
            return .just(.forgotPassword)
        case .register:
            return .just(.register)
        case .continueAsNotLogged:
            return .just(.continueAsNotLogged)
        }
    }
    /// Variable used to save if login is executed or not
    public var loginExecuted: Variable<Bool> = Variable(false)
    /// Variable used to save next screen that has to be opened after login
    public var nextViewModel: ViewModelType?
    
    // MARK: - Init methods
    
    public init() {
    }
    
    // MARK: - Login methods
    
    /**
     This method checks if username and password are defined, than asks to server info about this user. If the status code is 200 the user il logged in and next screen can be loaded. Errors are:
     - status 404, code "not_found"
     - msg "invalid_credentials"
     - msg "user_disabled"
     - Parameter username: The username inserted by the user
     - Parameter passowrd: The password inserted by the user
     */
    public func login(username: String, password: String) {
        if (username.isEmpty || password.isEmpty) {
            let message = "alert_loginMissingFields".localized()
            let dialog = ZAlertView(title: nil, message: message, closeButtonText: "btn_ok".localized(), closeButtonHandler: { alertView in
                alertView.dismissAlertView()
            })
            dialog.allowTouchOutsideToDismiss = false
            dialog.show()
        }
        let modifiedUsername = username.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        let modifiedPassword = password.md5!
        self.apiController.getUser(username: modifiedUsername, password: modifiedPassword)
            .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
            .subscribe { event in
                switch event {
                case .next(let response):
                    if response.status == 200, let data = response.dic_data {
                        if data["enabled"] as? Bool == false {
                            self.loginExecuted.value = false
                            let dispatchTime = DispatchTime.now() + 0.5
                            DispatchQueue.main.asyncAfter(deadline: dispatchTime) {
                                let message = "alert_loginUserNotEnabled".localized()
                                let dialog = ZAlertView(title: nil, message: message, closeButtonText: "btn_ok".localized(), closeButtonHandler: { alertView in
                                    alertView.dismissAlertView()
                                })
                                dialog.allowTouchOutsideToDismiss = false
                                dialog.show()
                            }
                            return
                        }
                        if let pin = data["pin"] {
                            KeychainSwift().set("\(String(describing: pin))", forKey: "UserPin")
                        }
                        if let firstname = data["name"] {
                            KeychainSwift().set("\(String(describing: firstname))", forKey: "UserFirstname")
                        }
                        if let bonus = data["bonus"] {
                            KeychainSwift().set("\(String(describing: bonus))", forKey: "UserBonus")
                        }
                        KeychainSwift().set(modifiedUsername, forKey: "Username")
                        KeychainSwift().set(modifiedPassword, forKey: "Password")
                        self.setupHistory()
                        self.setupFavourites()
                        self.setupSettings()
                        self.loginExecuted.value = true
                        CoreController.shared.updateData()
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateData"), object: nil)
                    }
                    else if response.status == 404, let code = response.code {
                        if code == "not_found" {
                            self.loginExecuted.value = false
                            let dispatchTime = DispatchTime.now() + 0.5
                            DispatchQueue.main.asyncAfter(deadline: dispatchTime) {
                                let message = "alert_loginWrongEmail".localized()
                                let dialog = ZAlertView(title: nil, message: message, closeButtonText: "btn_ok".localized(), closeButtonHandler: { alertView in
                                    alertView.dismissAlertView()
                                })
                                dialog.allowTouchOutsideToDismiss = false
                                dialog.show()
                            }
                        }
                    }
                    else if let msg = response.msg {
                        if msg == "invalid_credentials" {
                            self.loginExecuted.value = false
                            let dispatchTime = DispatchTime.now() + 0.5
                            DispatchQueue.main.asyncAfter(deadline: dispatchTime) {
                                let message = "alert_loginWrongPassword".localized()
                                let dialog = ZAlertView(title: nil, message: message, closeButtonText: "btn_ok".localized(), closeButtonHandler: { alertView in
                                    alertView.dismissAlertView()
                                })
                                dialog.allowTouchOutsideToDismiss = false
                                dialog.show()
                            }
                        } else if msg == "user_disabled" {
                            self.loginExecuted.value = false
                            let dispatchTime = DispatchTime.now() + 0.5
                            DispatchQueue.main.asyncAfter(deadline: dispatchTime) {
                                let message = "alert_loginUserDisabled".localized()
                                let dialog = ZAlertView(title: nil, message: message, closeButtonText: "btn_ok".localized(), closeButtonHandler: { alertView in
                                    alertView.dismissAlertView()
                                })
                                dialog.allowTouchOutsideToDismiss = false
                                dialog.show()
                            }
                        }
                    }
                case .error(_):
                    let dispatchTime = DispatchTime.now() + 0.5
                    DispatchQueue.main.asyncAfter(deadline: dispatchTime) {
                        self.loginExecuted.value = false
                        var message = "alert_generalError".localized()
                        if Reachability()?.isReachable == false {
                            message = "alert_connectionError".localized()
                        }
                        let dialog = ZAlertView(title: nil, message: message, closeButtonText: "btn_ok".localized(), closeButtonHandler: { alertView in
                            alertView.dismissAlertView()
                        })
                        dialog.allowTouchOutsideToDismiss = false
                        dialog.show()
                    }
                default:
                    break
                }
            }.addDisposableTo(self.disposeBag)
    }
    
    // MARK: - Setup methods
    
    /**
     This method setups default history array (address) in cache for user
     */
    public func setupHistory() {
        if var dictionary = UserDefaults.standard.object(forKey: "historyDic") as? [String: Data] {
            let archivedArray = NSKeyedArchiver.archivedData(withRootObject: [HistoryAddress]() as Array)
            if let username = KeychainSwift().get("Username") {
                dictionary[username] = archivedArray
                UserDefaults.standard.set(dictionary, forKey: "historyDic")
            }
        }
    }
    
    /**
    This method setups favorites empty array (address and feeds) in cache for user
    */
    public func setupFavourites() {
        if var dictionary = UserDefaults.standard.object(forKey: "favouritesAddressDic") as? [String: Data] {
            let archivedArray = NSKeyedArchiver.archivedData(withRootObject: [FavouriteAddress]() as Array)
            if let username = KeychainSwift().get("Username") {
                dictionary[username] = archivedArray
                UserDefaults.standard.set(dictionary, forKey: "favouritesAddressDic")
            }
        }
        if var dictionary = UserDefaults.standard.object(forKey: "favouritesFeedDic") as? [String: Data] {
            let archivedArray = NSKeyedArchiver.archivedData(withRootObject: [FavouriteFeed]() as Array)
            if let username = KeychainSwift().get("Username") {
                dictionary[username] = archivedArray
                UserDefaults.standard.set(dictionary, forKey: "favouritesFeedDic")
            }
        }
    }
    
    /**
     This method setups default settings (language) in cache for user
     */
    public func setupSettings() {
        var languageid = "0"
        if var dictionary = UserDefaults.standard.object(forKey: "languageDic") as? [String: String] {
            if let username = KeychainSwift().get("Username") {
                languageid = dictionary[username] ?? "0"
            }
        }
        if languageid == "0" {
            if var dictionary = UserDefaults.standard.object(forKey: "languageDic") as? [String: String] {
                if let username = KeychainSwift().get("Username") {
                    dictionary[username] = "language".localized()
                    UserDefaults.standard.set(dictionary, forKey: "languageDic")
                }
            }
        }
        Localize.setCurrentLanguage(languageid)
    }
}
