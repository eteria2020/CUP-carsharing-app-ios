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

enum LoginSelectionInput: SelectionInput {
    case login
    case forgotPassword
    case register
    case continueAsNotLogged
}

enum LoginSelectionOutput: SelectionOutput {
    case login
    case forgotPassword
    case register
    case continueAsNotLogged
}

final class LoginViewModel: ViewModelType {
    lazy var selection:Action<LoginSelectionInput,LoginSelectionOutput> = Action { input in
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
    
    fileprivate var apiController: ApiController = ApiController()
    var loginExecuted: Variable<Bool> = Variable(false)

    init() {
    }
    
    func login(username: String, password: String) {
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
                        if let pin = data["pin"] {
                            KeychainSwift().set("\(String(describing: pin))", forKey: "UserPin")
                        }
                        if let firstname = data["name"] {
                            KeychainSwift().set("\(String(describing: firstname))", forKey: "UserFirstname")
                        }
                        KeychainSwift().set(modifiedUsername, forKey: "Username")
                        KeychainSwift().set(modifiedPassword, forKey: "Password")
                        self.loginExecuted.value = true
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
}
