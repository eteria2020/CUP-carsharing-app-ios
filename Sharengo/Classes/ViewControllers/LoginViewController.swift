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

struct CustomTextInputStyle: AnimatedTextInputStyle {
    let activeColor = ColorBrand.black.value
    let inactiveColor = ColorBrand.gray.value
    let lineInactiveColor = ColorBrand.gray.value
    let errorColor = ColorBrand.black.value
    let textInputFont = Font.loginTextField.value
    let textInputFontColor = ColorBrand.black.value
    let placeholderMinFontSize: CGFloat = 9
    let counterLabelFont: UIFont? = Font.loginTextFieldPlaceholder.value
    let leftMargin: CGFloat = 20
    let topMargin: CGFloat = 25
    let rightMargin: CGFloat = 20
    let bottomMargin: CGFloat = 10
    let yHintPositionOffset: CGFloat = 7
    let yPlaceholderPositionOffset: CGFloat = 0
}

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
    fileprivate var introIsShowed: Bool = false
    
    var viewModel: LoginViewModel?
    var goBackAfterLogin: Bool = false
    var goToProfileAfterLogin: Bool = false
    
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
                        if self?.goBackAfterLogin == true && self != nil {
                            Router.back(self!)
                            return
                        } else if self?.goToProfileAfterLogin == true && self != nil {
                            let destination: ProfileViewController = (Storyboard.main.scene(.profile))
                            destination.bind(to: ViewModelFactory.profile(), afterLoad: true)
                            self?.navigationController?.pushViewController(destination, animated: true)
                    
                            return
                        }
                        let destination: HomeViewController = (Storyboard.main.scene(.home))
                        destination.bind(to: ViewModelFactory.home(), afterLoad: true)
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
        txt_email.style = CustomTextInputStyle()
        txt_password.type = .password
        txt_password.delegate = self
        txt_password.placeHolderText = "txt_loginPasswordPlaceholder".localized()
        txt_password.style = CustomTextInputStyle()
        #if ISDEBUG
            txt_email.text = "francesco.galatro@gmail.com"
            txt_password.text = "AppTest2017"
        #elseif ISRELEASE
        #endif
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
        self.btn_forgotPassword.style(.clearButton(Font.loginForgotPassword.value), title: "btn_loginForgotPassword".localized())
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if UserDefaults.standard.bool(forKey: "LoginShowed") == false {
            UserDefaults.standard.set(true, forKey: "LoginShowed")
            if !self.introIsShowed {
                let destination: IntroViewController  = (Storyboard.main.scene(.intro))
                destination.bind(to: ViewModelFactory.intro(), afterLoad: true)
                self.addChildViewController(destination)
                self.view.addSubview(destination.view)
                self.view.layoutIfNeeded()
            }
            self.introIsShowed = true
        }
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
