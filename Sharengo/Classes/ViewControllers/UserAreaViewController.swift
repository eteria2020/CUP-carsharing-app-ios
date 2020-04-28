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
import WebKit

class UserAreaViewController : BaseViewController, ViewModelBindable {
    @IBOutlet fileprivate weak var view_navigationBar: NavigationBarView!
    @IBOutlet fileprivate weak var view_header: UIView!
    @IBOutlet fileprivate weak var lbl_headerTitle: UILabel!
//    @IBOutlet fileprivate weak var webview_main: UIWebView!
    @IBOutlet weak var webview_container: UIView!
    @IBOutlet fileprivate var webview_main: WKWebView!
    
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
                
        URLSession.shared.reset {
            DispatchQueue.main.async {
                
                var request = URLRequest(url: URL(string: Config().userArea_EndPoint + "url_lang".localized())!)
                request.httpMethod = "POST"
                let username = KeychainSwift().get("Username")!.removingPercentEncoding ?? ""
                let password = KeychainSwift().get("PasswordClear")!
                let postString = "identity=\(username)&credential=\(password)"
                request.httpShouldHandleCookies = true
                request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
                request.httpBody = postString.data(using: .utf8)
                self.webview_main.load(request)
                
            }
        }
        
    }
    
    // MARK: - View methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let config = WKWebViewConfiguration()
        config.processPool = WKProcessPool()
    
        self.webview_main = WKWebView(frame: .zero, configuration: config)
        self.webview_main.navigationDelegate = self
        self.webview_container.backgroundColor = .clear
        self.webview_container.addSubview(self.webview_main)
        self.webview_main.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
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
        switch Device.current.diagonal {
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

// MARK: - WKNavigationDelegate
extension UserAreaViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Swift.Error) {
        //print("didFail")
        guard let error: NSError = error as? NSError else { return }
            let errorForm = -999
            let messageError = error.code
            if(messageError != errorForm){
                let dialog = ZAlertView(title: nil, message:  "alert_webViewError".localized(), closeButtonText: "btn_ok".localized(), closeButtonHandler: { alertView in
                    alertView.dismissAlertView()
                })
                dialog.allowTouchOutsideToDismiss = false
                dialog.show()
            }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        //print("didFinish")
        self.hideLoader {
        }
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        //print("decidePolicyForNavigation")
        print(navigationAction.request.url as Any)
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
        //print("didReceiveServerRedirectForProvisionalNavigation")
        if (self.webview_main!.url?.absoluteString == Config().disableReason_EndPoint)
        {
            print("AREA-UTENTE")
            self.webview_main!.stopLoading()
            let request = URLRequest(url: URL(string: Config().disableReason_EndPoint + "/mobile?url_lang".localized())!)
            self.webview_main.load(request)
        }
    }
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        //print("didCommitNavigation - content arriving?")
    }

    func webView(_ webView: WKWebView, didFailNavigation navigation: WKNavigation!, withError error: NSError) {
        //print("didFailNavigation")
    }

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        print("didStartProvisionalNavigation \(String(describing: navigation))")
    }
    
}

