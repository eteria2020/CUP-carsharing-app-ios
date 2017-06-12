//
//  LoginViewController.swift
//  Sharengo
//
//  Created by Dedecube on 12/06/17.
//  Copyright © 2017 Dedecube. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Boomerang
import DeviceKit
import TPKeyboardAvoiding

class LoginViewController : UIViewController, ViewModelBindable {
    @IBOutlet fileprivate weak var view_navigationBar: NavigationBarView!
    @IBOutlet fileprivate weak var scrollView_main: TPKeyboardAvoidingScrollView!
    @IBOutlet fileprivate weak var view_scrollViewContainer: UIView!
    @IBOutlet fileprivate weak var lbl_formHeader: UILabel!
    @IBOutlet fileprivate weak var txt_email: AnimatedTextInput!
    @IBOutlet fileprivate weak var txt_password: AnimatedTextInput!
    @IBOutlet fileprivate weak var btn_forgotPassword: UIButton!
    @IBOutlet fileprivate weak var btn_login: UIButton!
    @IBOutlet fileprivate weak var view_bottom: UIView!
    @IBOutlet fileprivate weak var lbl_notYetRegistered: UILabel!
    @IBOutlet fileprivate weak var btn_register: UIButton!
    @IBOutlet fileprivate weak var btn_continueAsNotLogged: UIButton!
    
    var viewModel: LoginViewModel?
    
    // MARK: - ViewModel methods
    
    func bind(to viewModel: ViewModelType?) {
        guard let viewModel = viewModel as? LoginViewModel else {
            return
        }
        self.viewModel = viewModel

        self.btn_login.rx.bind(to: viewModel.selection, input: .login)
        self.btn_forgotPassword.rx.bind(to: viewModel.selection, input: .forgotPassword)
        self.btn_register.rx.bind(to: viewModel.selection, input: .register)
        self.btn_continueAsNotLogged.rx.bind(to: viewModel.selection, input: .continueAsNotLogged)
        
        viewModel.loginExecuted.asObservable()
            .subscribe(onNext: {[weak self] (loginExecuted) in
                DispatchQueue.main.async {
                    self?.hideLoader()
                    if loginExecuted {
                        // TODO: refactoring
                        let destination:CarBookingCompletedViewController = (Storyboard.main.scene(.carBookingCompleted))
                        let viewModel = ViewModelFactory.carBookingCompleted(carTrip: CarTrip(car: Car()))
                        destination.bind(to: viewModel, afterLoad: true)
                        self?.navigationController?.pushViewController(destination, animated: true)
                    } else {
                        self?.hideLoader()
                    }
                }
            }).addDisposableTo(disposeBag)
    }
    
    // MARK: - View methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.layoutIfNeeded()

        self.view.backgroundColor = Color.loginBackground.value

        // TextField
        txt_email.type = .email
        txt_email.delegate = self
        txt_email.placeHolderText = "txt_loginEmailPlaceholder".localized()
        txt_password.type = .password
        txt_password.delegate = self
        txt_password.placeHolderText = "txt_loginPasswordPlaceholder".localized()
        
        txt_email.text = "francesco.galatro@gmail.com"
        txt_password.text = "AppTest2017"
        
        // TODO: ???
        /*case loginEmail = "loginEmail"
        case loginEmailPlaceholder = "loginEmailPlaceholder"
        case loginPassword = "loginPassword"
        case loginPasswordPlaceholder = "loginPasswordPlaceholder"*/

        // Buttons
        switch Device().diagonal {
            case 3.5:
                self.btn_register.constraint(withIdentifier: "buttonHeight", searchInSubviews: false)?.constant = 30
            case 4:
                self.btn_register.constraint(withIdentifier: "buttonHeight", searchInSubviews: false)?.constant = 33
            default:
                self.btn_register.constraint(withIdentifier: "buttonHeight", searchInSubviews: false)?.constant = 35
        }
        self.btn_forgotPassword.style(.roundedButton(Color.alertButtonsPositiveBackground.value), title: "btn_loginForgotPassword".localized())
        self.btn_login.style(.roundedButton(Color.alertButtonsPositiveBackground.value), title: "btn_loginLogin".localized())
        self.btn_register.style(.roundedButton(Color.alertButtonsPositiveBackground.value), title: "btn_loginRegister".localized())
        self.btn_continueAsNotLogged.style(.roundedButton(Color.alertButtonsPositiveBackground.value), title: "btn_loginContinueAsNotLogged".localized())
        self.viewModel?.selection.elements.subscribe(onNext:{[weak self] output in
            if (self == nil) { return }
            switch output {
            case .login:
                self?.showLoader()
                self?.viewModel?.login(username: (self?.txt_email.text)!, password: (self?.txt_password.text)!)
            default:
                break
            }
        }).addDisposableTo(self.disposeBag)

        // Labels
        self.lbl_formHeader.styledText = "lbl_loginFormHeader".localized()
        self.lbl_notYetRegistered.styledText = "lbl_loginNotYetRegistered".localized()
        
        // NavigationBar
        self.view_navigationBar.bind(to: ViewModelFactory.navigationBar(leftItemType: .home, rightItemType: .menu))
        self.view_navigationBar.viewModel?.selection.elements.subscribe(onNext:{[weak self] output in
            if (self == nil) { return }
            switch output {
            case .home:
                Router.exit(self!)
            case .menu:
                print("Open menu")
                break
            default:
                break
            }
        }).addDisposableTo(self.disposeBag)
    }
}

// MARK: - TextField delegate

extension LoginViewController: AnimatedTextInputDelegate
{
    func animatedTextInputShouldReturn(animatedTextInput: AnimatedTextInput) -> Bool
    {
        _ = animatedTextInput.resignFirstResponder()
        
        return true
    }
}
