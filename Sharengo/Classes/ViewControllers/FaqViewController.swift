//
//  FaqViewController.swift
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
import WebKit

class FaqViewController : BaseViewController, ViewModelBindable {
    @IBOutlet fileprivate weak var view_navigationBar: NavigationBarView!
    @IBOutlet fileprivate weak var view_header: UIView!
    @IBOutlet fileprivate weak var lbl_headerTitle: UILabel!
    //@IBOutlet fileprivate weak var webview_main: UIWebView!
    @IBOutlet fileprivate weak var btn_appTutorial: UIButton!
    @IBOutlet weak var webview_container: UIView!
    @IBOutlet fileprivate var webview_main: WKWebView!
    
    var viewModel: FaqViewModel?
    
    // MARK: - ViewModel methods
    
    func bind(to viewModel: ViewModelType?) {
        guard let viewModel = viewModel as? FaqViewModel else {
            return
        }
        
        let config = WKWebViewConfiguration()
        config.processPool = WKProcessPool()
            
        self.webview_main = WKWebView(frame: .zero, configuration: config)
        self.webview_main.navigationDelegate = self
        self.webview_container.backgroundColor = .clear
        self.webview_container.addSubview(self.webview_main)
        self.webview_main.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
          
        self.viewModel = viewModel
        if let request = viewModel.urlRequest {
            self.webview_main.load(request)
        }
        self.viewModel?.selection.elements.subscribe(onNext:{[weak self] output in
            if (self == nil) { return }
            switch output {
            case .tutorial:
                let destination: TutorialViewController = (Storyboard.main.scene(.tutorial))
                let viewModel = ViewModelFactory.tutorial()
                destination.bind(to: viewModel, afterLoad: true)
                self?.present(destination, animated: true, completion: nil)
            }
        }).disposed(by: self.disposeBag)
        self.btn_appTutorial.rx.bind(to: viewModel.selection, input: .tutorial)
    }
    
    // MARK: - View methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.layoutIfNeeded()
        
        // Views
        self.view.backgroundColor = Color.faqBackground.value
        self.webview_main.isOpaque = false
        self.webview_main.backgroundColor = UIColor.clear
        self.webview_main.scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        self.webview_main.scrollView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        self.webview_main.scrollView.showsHorizontalScrollIndicator = false
        self.webview_main.scrollView.showsVerticalScrollIndicator = false
        self.view_header.backgroundColor = Color.faqHeaderBackground.value
        
        // Buttons
        self.btn_appTutorial.style(.squaredButton(Color.faqAppTutorialButton.value), title: "btn_faqAppTutorial".localized())
        if (self.btn_appTutorial.currentTitle == "--") {
            self.btn_appTutorial.isHidden = true
        }
        
        // Labels
        self.lbl_headerTitle.textColor = Color.faqHeaderTitle.value
        self.lbl_headerTitle.styledText = "lbl_faqHeader".localized().uppercased()
        
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
            self.btn_appTutorial.constraint(withIdentifier: "buttonHeight", searchInSubviews: false)?.constant = 33
        case 4:
            self.view_header.constraint(withIdentifier: "viewHeaderHeight", searchInSubviews: true)?.constant = 30
            self.btn_appTutorial.constraint(withIdentifier: "buttonHeight", searchInSubviews: false)?.constant = 36
        case 4.7:
            self.view_header.constraint(withIdentifier: "viewHeaderHeight", searchInSubviews: true)?.constant = 32
            self.btn_appTutorial.constraint(withIdentifier: "buttonHeight", searchInSubviews: false)?.constant = 38
        case 5.5:
            self.view_header.constraint(withIdentifier: "viewHeaderHeight", searchInSubviews: true)?.constant = 32
            self.btn_appTutorial.constraint(withIdentifier: "buttonHeight", searchInSubviews: false)?.constant = 38
        case 5.8:
            self.view_header.constraint(withIdentifier: "viewHeaderHeight", searchInSubviews: true)?.constant = 34
            self.btn_appTutorial.constraint(withIdentifier: "buttonHeight", searchInSubviews: false)?.constant = 40
        default:
            break
        }
    }
}

extension FaqViewController: WKNavigationDelegate {

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Swift.Error) {
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
        self.hideLoader {
            
        }
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        decisionHandler(.allow)
    }
}
