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

enum LoginSelectionInput: SelectionInput {
    case login
    case forgotPassword
    case register
    case continueAsNotLogged
}

enum LoginSelectionOutput: SelectionOutput {
    case viewModel(ViewModelType)
    case login
    case empty
}

final class LoginViewModel: ViewModelType {
    lazy var selection:Action<LoginSelectionInput,LoginSelectionOutput> = Action { input in
        switch input {
        case .login:
            return .just(.login)
        case .forgotPassword:
            return .just(.empty)
        case .register:
            return .just(.empty)
        case .continueAsNotLogged:
            return .just(.empty)
        }
    }
    fileprivate var apiController: ApiController = ApiController()
    var loginExecuted: Variable<Bool> = Variable(false)

    init() {
    }
    
    func login(username: String, password: String)
    {
        if (username.isEmpty || password.isEmpty)
        {
            let message = "alert_loginMissingFields".localized()
            let dialog = ZAlertView(title: nil, message: message, closeButtonText: "btn_ok".localized(), closeButtonHandler: { alertView in
                alertView.dismissAlertView()
            })
            dialog.allowTouchOutsideToDismiss = false
            dialog.show()
        }
        
        self.apiController.getUser(username: username.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!, password: password.md5!)
            .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
            .subscribe { event in
                switch event {
                case .next(let response):
                    if response.status == 200, let data = response.dic_data {
                        UserDefaults.standard.set(data["pin"], forKey: "UserPin")
                        UserDefaults.standard.set(username, forKey: "Username")
                        UserDefaults.standard.set(password.md5!, forKey: "Password")

                        self.loginExecuted.value = true
                    }
                    else if response.status == 404, let data = response.dic_data {
                        if data["code"] as! String  == "not_found"
                        {
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
                    else if response.status == 406, let data = response.dic_data {
                        if data["msg"] as! String == "invalid_credentials"
                        {
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
