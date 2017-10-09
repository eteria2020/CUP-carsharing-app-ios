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
import SideMenu

/**
 The Login class is used by user to authenticate himself to enjoy more features
 */
public class LoginViewController : BaseViewController, ViewModelBindable {
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
    @IBOutlet fileprivate weak var view_white: UIView!
    /// Variable used to save if the intro is already showed
    public var introIsShowed: Bool = false
    /// User can open profile eco status
    public var profileEcoStatusAvailable: Bool = false
    /// ViewModel variable used to represents the data
    public var viewModel: LoginViewModel?
    
    // MARK: - ViewModel methods
    
    public func bind(to viewModel: ViewModelType?) {
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
                DispatchQueue.main.async {[weak self]  in
                    self?.hideLoader(completionClosure: { () in
                        if loginExecuted {
                            if self != nil {
                                if let viewModel = viewModel.nextViewModel {
                                    if viewModel is ProfileViewModel && self?.profileEcoStatusAvailable == false {
                                        Router.exit(self!)
                                    } else {
                                        Router.from(self!, viewModel: viewModel).execute()
                                    }
                                } else if self?.introIsShowed == true {
                                    Router.exit(self!)
                                } else {
                                    Router.back(self!)
                                }
                            }
                        }
                    })
                }
            }).addDisposableTo(disposeBag)
    }
    
    // MARK: - View methods
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        self.view.layoutIfNeeded()
        self.view.backgroundColor = Color.loginBackground.value
        // TextField
        txt_email.type = .email
        txt_email.delegate = self
        txt_email.placeHolderText = "txt_loginEmailPlaceholder".localized()
        txt_email.style = CustomTextInputStyle1()
        txt_password.type = .password
        txt_password.delegate = self
        txt_password.placeHolderText = "txt_loginPasswordPlaceholder".localized()
        txt_password.style = CustomTextInputStyle1()
        #if ISDEBUG
            //txt_email.text = "emilio.cristiano@tiscali.it"
            //txt_password.text = "Sharengo2016!"
            txt_email.text = "francesco.galatro@gmail.com"
            txt_password.text = "AppTest2017"
        #elseif ISRELEASE
        #endif
        if self.introIsShowed {
            UIView.animate(withDuration: 0.5, animations: {
                self.view_white.alpha = 0.0
            })
        } else {
            self.view_white.alpha = 0.0
        }
        // Buttons
        switch Device().diagonal {
            case 3.5:
                self.btn_login.constraint(withIdentifier: "buttonHeight", searchInSubviews: false)?.constant = 33
                self.btn_register.constraint(withIdentifier: "buttonHeight", searchInSubviews: false)?.constant = 33
                self.btn_continueAsNotLogged.constraint(withIdentifier: "buttonHeight", searchInSubviews: false)?.constant = 33
                self.view.constraint(withIdentifier: "topTxtEmail", searchInSubviews: true)?.constant = 5
                self.view.constraint(withIdentifier: "topTxtPassword", searchInSubviews: true)?.constant = 5
                self.view.constraint(withIdentifier: "topBtnForgotPassword", searchInSubviews: true)?.constant = 5
            case 4:
                self.btn_login.constraint(withIdentifier: "buttonHeight", searchInSubviews: false)?.constant = 36
                self.btn_register.constraint(withIdentifier: "buttonHeight", searchInSubviews: false)?.constant = 36
                self.btn_continueAsNotLogged.constraint(withIdentifier: "buttonHeight", searchInSubviews: false)?.constant = 36
            default:
                self.btn_login.constraint(withIdentifier: "buttonHeight", searchInSubviews: false)?.constant = 38
                self.btn_register.constraint(withIdentifier: "buttonHeight", searchInSubviews: false)?.constant = 38
                self.btn_continueAsNotLogged.constraint(withIdentifier: "buttonHeight", searchInSubviews: false)?.constant = 38
        }
        self.btn_forgotPassword.style(.clearButton(Font.loginForgotPassword.value, Color.alertButton.value), title: "btn_loginForgotPassword".localized())
        self.btn_forgotPassword.contentHorizontalAlignment = UIControlContentHorizontalAlignment.left
        self.btn_login.style(.roundedButton(Color.alertButtonsPositiveBackground.value), title: "btn_loginLogin".localized())
        self.btn_register.style(.roundedButton(Color.alertButtonsPositiveBackground.value), title: "btn_loginRegister".localized())
        self.btn_continueAsNotLogged.style(.squaredButton(Color.loginContinueAsNotLoggedButton.value), title: "btn_loginContinueAsNotLogged".localized())
        self.viewModel?.selection.elements.subscribe(onNext:{[weak self] output in
            if (self == nil) { return }
            self?.view.endEditing(true)
            switch output {
            case .forgotPassword:
                let destination: WebViewController = (Storyboard.main.scene(.web))
                let viewModel = ViewModelFactory.web(with: WebType.forgotPassword)
                destination.bind(to: viewModel, afterLoad: true)
                self?.navigationController?.pushViewController(destination, animated: true)
            case .login:
                self?.showLoader()
                self?.viewModel?.login(username: (self?.txt_email.text)!, password: (self?.txt_password.text)!)
            case .register:
                let destination: SignupViewController = (Storyboard.main.scene(.signup))
                destination.bind(to: ViewModelFactory.signup(), afterLoad: true)
                self?.navigationController?.pushViewController(destination, animated: true)
            case .continueAsNotLogged:
                let destination: HomeViewController = (Storyboard.main.scene(.home))
                destination.introIsShowed = true
                destination.bind(to: ViewModelFactory.home(), afterLoad: true)
                self?.navigationController?.pushViewController(destination, animated: true)
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
                self?.present(SideMenuManager.menuRightNavigationController!, animated: true, completion: nil)
            default:
                break
            }
        }).addDisposableTo(self.disposeBag)
    }
}

extension LoginViewController: AnimatedTextInputDelegate {
    // MARK: - TextField delegate
    
    /**
     This method is called when user try to close keyboard
     */
    public func animatedTextInputShouldReturn(animatedTextInput: AnimatedTextInput) -> Bool {
        _ = animatedTextInput.resignFirstResponder()
        return true
    }
}
