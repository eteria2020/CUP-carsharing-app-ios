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

class FaqViewController : BaseViewController, ViewModelBindable {
    @IBOutlet fileprivate weak var view_navigationBar: NavigationBarView!
    @IBOutlet fileprivate weak var view_header: UIView!
    @IBOutlet fileprivate weak var lbl_headerTitle: UILabel!
    @IBOutlet fileprivate weak var webview_main: UIWebView!
    @IBOutlet fileprivate weak var btn_appTutorial: UIButton!
    
    var viewModel: FaqViewModel?
    var firstCall: Bool = true
    
    // MARK: - ViewModel methods
    
    func bind(to viewModel: ViewModelType?) {
        guard let viewModel = viewModel as? FaqViewModel else {
            return
        }
        self.viewModel = viewModel
        if let request = viewModel.urlRequest {
            self.webview_main.loadRequest(request)
        }
    }
    
    // MARK: - View methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.layoutIfNeeded()
        self.view.backgroundColor = Color.webBackground.value
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
        self.webview_main.isOpaque = false
        self.webview_main.backgroundColor = UIColor.clear
        self.webview_main.scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        self.webview_main.scrollView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        self.webview_main.scrollView.showsHorizontalScrollIndicator = false
        self.webview_main.scrollView.showsVerticalScrollIndicator = false
    }
}

extension FaqViewController: UIWebViewDelegate {
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
//        if let type = viewModel?.type {
//            switch type {
//            case .forgotPassword:
//                if request.httpBody != nil {
//                    if let returnData = String(data: request.httpBody!, encoding: .utf8) {
//                        if returnData.contains("email=") {
//                            let dispatchTime = DispatchTime.now() + 3
//                            DispatchQueue.main.asyncAfter(deadline: dispatchTime) {
//                                Router.back(self)
//                            }
//                        }
//                    }
//                }
//            case .signup:
//                if request.url?.absoluteString == "http://www.sharengo.it/signup-3/mobile" {
//                    let dispatchTime = DispatchTime.now() + 3
//                    DispatchQueue.main.asyncAfter(deadline: dispatchTime) {
//                        if let viewControllers = self.navigationController?.viewControllers {
//                            if let currentIndex = viewControllers.index(of: self)  {
//                                if currentIndex-2 >= 0 {
//                                    self.navigationController?.popToViewController(viewControllers[currentIndex-2], animated: true)
//                                }
//                            }
//                        }
//                    }
//                }
//            default:
//                break
//            }
//        }
        return true
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Swift.Error) {
        let dialog = ZAlertView(title: nil, message: "alert_webViewError".localized(), closeButtonText: "btn_ok".localized(), closeButtonHandler: { alertView in
            alertView.dismissAlertView()
            Router.back(self)
        })
        dialog.allowTouchOutsideToDismiss = false
        dialog.show()
    }
}
