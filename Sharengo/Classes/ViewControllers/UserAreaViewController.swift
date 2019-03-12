//
//  UserAreaViewController.swift
//  Sharengo
//
//  Created by Dedecube on 26/07/17.
//  Copyright © 2017 Dedecube. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

import SideMenu
import DeviceKit
import KeychainSwift

class UserAreaViewController : BaseViewController, ViewModelBindable {
    @IBOutlet fileprivate weak var view_navigationBar: NavigationBarView!
    @IBOutlet fileprivate weak var view_header: UIView!
    @IBOutlet fileprivate weak var lbl_headerTitle: UILabel!
    @IBOutlet fileprivate weak var webview_main: UIWebView!
    
    var viewModel: UserAreaViewModel?
    static var destination = ""
    
    // MARK: - ViewModel methods
    public func launchAssistence() {
        let destination: SupportViewController = (Storyboard.main.scene(.support))
        destination.bind(to: viewModel, afterLoad: true)
        CoreController.shared.currentViewController?.navigationController?.pushViewController(destination, animated: false)
    }
    
    func bind(to viewModel: ViewModelType?) {
        guard let viewModel = viewModel as? UserAreaViewModel else {
            return
        }
        self.viewModel = viewModel
        self.viewModel?.selection.elements.subscribe(onNext:{[weak self] output in
            if (self == nil) { return }
            switch output {
            default:
                break
            }
        }).disposed(by: self.disposeBag)
        
        self.showLoader()
        URLSession.shared.reset { 
            var request = URLRequest(url: URL(string: "url_ita_userArea".localized())!)
            request.httpMethod = "POST"
            let username = KeychainSwift().get("Username")!
            let password = KeychainSwift().get("PasswordClear")!
            let postString = "identity=\(username)&credential=\(password)"
            request.httpBody = postString.data(using: .utf8)
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                self.hideLoader {
                    guard let _ = data, error == nil else {
                        let dialog = ZAlertView(title: nil, message: "alert_webViewError".localized(), isOkButtonLeft: false, okButtonText: "btn_ok".localized(), cancelButtonText: "btn_back".localized(),
                                                okButtonHandler: { alertView in
                                                   /* let destination: TutorialViewController = (Storyboard.main.scene(.tutorial))
                                                    let viewModel = ViewModelFactory.tutorial()
                                                    destination.bind(to: viewModel, afterLoad: true)
                                                    self.present(destination, animated: true, completion: nil)*/
                                                    alertView.dismissAlertView()
                        },
                                                cancelButtonHandler: { alertView in
                                                    Router.back(self)
                                                    alertView.dismissAlertView()
                        })
                        dialog.allowTouchOutsideToDismiss = false
                        dialog.show()
                        return
                    }
                   
                        if KeychainSwift().get("DisableReason") != nil {
                            let url = URL(string: "url_ita_disableReason".localized())
                            self.webview_main.loadRequest(URLRequest(url: url!, cachePolicy: URLRequest.CachePolicy.reloadIgnoringCacheData, timeoutInterval: 30.0))
//                            let disableReason = KeychainSwift().get("DisableReason")!
//                            switch disableReason{
//                            case "FAILED_PAYMENT":
//                                    let url = URL(string: "https://www.sharengo.it/area-utente/mobile")
//                                    self.webview_main.loadRequest(URLRequest(url: url!, cachePolicy: URLRequest.CachePolicy.reloadIgnoringCacheData, timeoutInterval: 30.0))
//                               case "FIRST_PAYMENT_NOT_COMPLETED":
//                                    let url = URL(string: "https://www.sharengo.it/area-utente/dati-pagamento/mobile")
//                                    self.webview_main.loadRequest(URLRequest(url: url!, cachePolicy: URLRequest.CachePolicy.reloadIgnoringCacheData, timeoutInterval: 30.0))
//                                 case "INVALID_DRIVERS_LICENSE":
//                                    let url = URL(string: "https://www.sharengo.it/area-utente/patente/mobile")
//                                    self.webview_main.loadRequest(URLRequest(url: url!, cachePolicy: URLRequest.CachePolicy.reloadIgnoringCacheData, timeoutInterval: 30.0))
//                                 /*case "DISABLED_BY_WEBUSER":
//                                    //va nella view di assistenza gestista al click dell'okkei va nel default e apre la home al secondo click.
//                                    self.launchAssistence()*/
//                                case "EXPIRED_DRIVERS_LICENSE":
//                                        let url = URL(string: "https://www.sharengo.it/area-utente/patente/mobile")
//                                        self.webview_main.loadRequest(URLRequest(url: url!, cachePolicy: URLRequest.CachePolicy.reloadIgnoringCacheData, timeoutInterval: 30.0))
//                                case "EXPIRED_CREDIT_CARD":
//                                    let url = URL(string: "https://www.sharengo.it/area-utente/dati-pagamento/mobile")
//                                    self.webview_main.loadRequest(URLRequest(url: url!, cachePolicy: URLRequest.CachePolicy.reloadIgnoringCacheData, timeoutInterval: 30.0))
//                                case "REGISTRATION_NOT_COMPLETED":
//                                    let url = URL(string: "https://www.sharengo.it/area-utente/mobile")
//                                    self.webview_main.loadRequest(URLRequest(url: url!, cachePolicy: URLRequest.CachePolicy.reloadIgnoringCacheData, timeoutInterval: 30.0))
//
//                            default:
//
//                                let url = URL(string: "https://www.sharengo.it/area-utente/mobile")
//                                self.webview_main.loadRequest(URLRequest(url: url!, cachePolicy: URLRequest.CachePolicy.reloadIgnoringCacheData, timeoutInterval: 30.0))
//                            }
                        }
                        else{
                            let url = URL(string: "url_ita_disableReason".localized())
                            self.webview_main.loadRequest(URLRequest(url: url!, cachePolicy: URLRequest.CachePolicy.reloadIgnoringCacheData, timeoutInterval: 30.0))
                        }
                }
            }
            task.resume()
        }
    }
    
    // MARK: - View methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.layoutIfNeeded()
        
        // Views
        self.view.backgroundColor = Color.userAreaBackground.value
        self.webview_main.isOpaque = false
        self.webview_main.backgroundColor = UIColor.clear
        self.webview_main.scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        self.webview_main.scrollView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        self.webview_main.scrollView.showsHorizontalScrollIndicator = false
        self.webview_main.scrollView.showsVerticalScrollIndicator = false
        self.view_header.backgroundColor = Color.userAreaHeaderBackground.value
        
        // Labels
        self.lbl_headerTitle.textColor = Color.userAreaHeaderTitle.value
        self.lbl_headerTitle.styledText = "lbl_userAreaHeader".localized().uppercased()
        
        // NavigationBar
        self.view_navigationBar.bind(to: ViewModelFactory.navigationBar(leftItemType: .home, rightItemType: .menu))
        self.view_navigationBar.viewModel?.selection.elements.subscribe(onNext:{[weak self] output in
            if (self == nil) { return }
            switch output {
            case .home:
                Router.exit(self!)
            case .menu:
                self?.present(SideMenuManager.default.menuRightNavigationController!, animated: true, completion: nil)
            default:
                break
            }
        }).disposed(by: self.disposeBag)
        
        // Other
        switch Device().diagonal {
        case 3.5:
            self.view_header.constraint(withIdentifier: "viewHeaderHeight", searchInSubviews: true)?.constant = 30
        case 4:
            self.view_header.constraint(withIdentifier: "viewHeaderHeight", searchInSubviews: true)?.constant = 30
        case 4.7:
            self.view_header.constraint(withIdentifier: "viewHeaderHeight", searchInSubviews: true)?.constant = 32
        case 5.5:
            self.view_header.constraint(withIdentifier: "viewHeaderHeight", searchInSubviews: true)?.constant = 32
        case 5.8:
            self.view_header.constraint(withIdentifier: "viewHeaderHeight", searchInSubviews: true)?.constant = 34
        default:
            break
        }
    }
}

extension UserAreaViewController: UIWebViewDelegate {
    private func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebView.NavigationType) -> Bool {
        print(webView.request?.description)
        return true
    }
    func webView(_ webView: UIWebView, didFailLoadWithError error: NSError) {
        
        let errorForm = -999
        let messageError = error.code
        if(messageError != errorForm){
            let dialog = ZAlertView(title: nil, message:  "alert_webViewError".localized(), closeButtonText: "btn_ok".localized(), closeButtonHandler: { alertView in
                alertView.dismissAlertView()
            })
            dialog.allowTouchOutsideToDismiss = false
            dialog.show()
        }
       /* let dialog = ZAlertView(title: nil, message: "alert_webViewError".localized(), isOkButtonLeft: false, okButtonText: "btn_tutorial".localized(), cancelButtonText: "btn_back".localized(),
                                okButtonHandler: { alertView in
                                    let destination: TutorialViewController = (Storyboard.main.scene(.tutorial))
                                    let viewModel = ViewModelFactory.tutorial()
                                    destination.bind(to: viewModel, afterLoad: true)
                                    self.present(destination, animated: true, completion: nil)
                                    alertView.dismissAlertView()
        },
                                cancelButtonHandler: { alertView in
                                    Router.back(self)
                                    alertView.dismissAlertView()
        })
        dialog.allowTouchOutsideToDismiss = false
        dialog.show()*/
    }
    
    
}
