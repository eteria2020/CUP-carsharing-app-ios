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
import Boomerang
import SideMenu
import DeviceKit

/**
 The FaqViewController class shows faqs to user
 */
public class FaqViewController : BaseViewController, ViewModelBindable {
    @IBOutlet fileprivate weak var view_navigationBar: NavigationBarView!
    @IBOutlet fileprivate weak var view_header: UIView!
    @IBOutlet fileprivate weak var lbl_headerTitle: UILabel!
    @IBOutlet fileprivate weak var webview_main: UIWebView!
    @IBOutlet fileprivate weak var btn_appTutorial: UIButton!
    /// ViewModel variable used to represents the data
    public var viewModel: FaqViewModel?
    
    // MARK: - ViewModel methods
    
    public func bind(to viewModel: ViewModelType?) {
        guard let viewModel = viewModel as? FaqViewModel else {
            return
        }
        self.viewModel = viewModel
        if let request = viewModel.urlRequest {
            self.webview_main.loadRequest(request)
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
        }).addDisposableTo(self.disposeBag)
        self.btn_appTutorial.rx.bind(to: viewModel.selection, input: .tutorial)
    }
    
    // MARK: - View methods
    
    override public func viewDidLoad() {
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
        }).addDisposableTo(self.disposeBag)
        
        // Other
        switch Device().diagonal {
        case 3.5:
            self.view_header.constraint(withIdentifier: "viewHeaderHeight", searchInSubviews: true)?.constant = 30
            self.btn_appTutorial.constraint(withIdentifier: "buttonHeight", searchInSubviews: false)?.constant = 33
        case 4:
            self.view_header.constraint(withIdentifier: "viewHeaderHeight", searchInSubviews: true)?.constant = 30
            self.btn_appTutorial.constraint(withIdentifier: "buttonHeight", searchInSubviews: false)?.constant = 36
        case 4.7, 5.8:
            self.view_header.constraint(withIdentifier: "viewHeaderHeight", searchInSubviews: true)?.constant = 32
            self.btn_appTutorial.constraint(withIdentifier: "buttonHeight", searchInSubviews: false)?.constant = 38
        default:
            self.view_header.constraint(withIdentifier: "viewHeaderHeight", searchInSubviews: true)?.constant = 32
            self.btn_appTutorial.constraint(withIdentifier: "buttonHeight", searchInSubviews: false)?.constant = 38
        }
    }
}

extension FaqViewController: UIWebViewDelegate {
    /**
     With this method app starts loading url
     */
    public func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        return true
    }

    /**
     With this method app shows to user if there was an error loading url page
     */
    public func webView(_ webView: UIWebView, didFailLoadWithError error: Swift.Error) {
        let dialog = ZAlertView(title: nil, message: "alert_webViewError".localized(), isOkButtonLeft: false, okButtonText: "btn_tutorial".localized(), cancelButtonText: "btn_back".localized(),
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
        dialog.show()
    }
}
