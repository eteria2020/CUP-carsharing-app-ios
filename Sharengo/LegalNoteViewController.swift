//
//  LegalViewController.swift
//  Sharengo
//
//  Created by sharengo on 09/05/18.
//  Copyright © 2018 CSGroup. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

import SideMenu
import DeviceKit
import KeychainSwift

class LegalNoteViewController : BaseViewController, ViewModelBindable {
    @IBOutlet fileprivate weak var view_navigationBar: NavigationBarView!
    @IBOutlet fileprivate weak var view_header: UIView!
    @IBOutlet fileprivate weak var lbl_headerTitle: UILabel!
    @IBOutlet fileprivate weak var webview_main: UIWebView!
    
    var viewModel: LegalNoteViewModel?
    static var destination = ""
    
    // MARK: - ViewModel methods

    
    func bind(to viewModel: ViewModelType?) {
        guard let viewModel = viewModel as? LegalNoteViewModel else {
            return
        }
        self.viewModel = viewModel
        self.viewModel?.selection.elements.subscribe(onNext:{[weak self] output in
            if (self == nil) { return }
            switch output {
            default:
                break
            }
        }).addDisposableTo(self.disposeBag)
        
     
        URLSession.shared.reset {

            let url = URL(string: "url_ita_noteLegali".localized())
            self.webview_main.loadRequest(URLRequest(url: url!, cachePolicy: URLRequest.CachePolicy.reloadIgnoringCacheData, timeoutInterval: 30.0))
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
        self.lbl_headerTitle.styledText = "lbl_legalNoteHeader".localized().uppercased()
        
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
        }).addDisposableTo(self.disposeBag)
        
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

extension LegalNoteViewController: UIWebViewDelegate {
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        return true
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Swift.Error) {
//        let dialog = ZAlertView(title: nil, message: "alert_webViewError".localized(), isOkButtonLeft: false, okButtonText: "btn_tutorial".localized(), cancelButtonText: "btn_back".localized(),
//                                okButtonHandler: { alertView in
//                                    let destination: TutorialViewController = (Storyboard.main.scene(.tutorial))
//                                    let viewModel = ViewModelFactory.tutorial()
//                                    destination.bind(to: viewModel, afterLoad: true)
//                                    self.present(destination, animated: true, completion: nil)
//                                    alertView.dismissAlertView()
//        },
//                                cancelButtonHandler: { alertView in
//                                    Router.back(self)
//                                    alertView.dismissAlertView()
//        })
//        dialog.allowTouchOutsideToDismiss = false
//        dialog.show()
        let dialog = ZAlertView(title: nil, message: "alert_webViewError".localized(), isOkButtonLeft: false, okButtonText: "btn_ok".localized(), cancelButtonText: "btn_back".localized(),
                                okButtonHandler: { alertView in
                                    alertView.dismissAlertView() },
                                
                                cancelButtonHandler: { alertView in
                                Router.back(self)
                                 alertView.dismissAlertView()
        })
        dialog.allowTouchOutsideToDismiss = false
        dialog.show()
    }
}

