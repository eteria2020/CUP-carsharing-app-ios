//
//  SupportViewController.swift
//  Sharengo
//
//  Created by Dedecube on 19/07/17.
//  Copyright © 2017 Dedecube. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Boomerang
import SideMenu
import DeviceKit

/**
 The Support class allows the user to call Share'ngo team if he needs help
 */
public class SupportViewController : BaseViewController, ViewModelBindable {
    @IBOutlet fileprivate weak var view_navigationBar: NavigationBarView!
    @IBOutlet fileprivate weak var view_header: UIView!
    @IBOutlet fileprivate weak var lbl_headerTitle: UILabel!
    @IBOutlet fileprivate weak var img_top: UIImageView!
    @IBOutlet fileprivate weak var lbl_title: UILabel!
    @IBOutlet fileprivate weak var lbl_subtitle: UILabel!
    @IBOutlet fileprivate weak var btn_call: UIButton!
    @IBOutlet fileprivate weak var view_callArea: UIView!
    /// ViewModel variable used to represents the data
    public var viewModel: SupportViewModel?
    
    // MARK: - ViewModel methods
    
    public func bind(to viewModel: ViewModelType?) {
        guard let viewModel = viewModel as? SupportViewModel else {
            return
        }
        viewModel.selection.elements.subscribe(onNext:{ selection in
            switch selection {
            default: break
            }
        }).addDisposableTo(self.disposeBag)
        self.viewModel = viewModel
    }
    
    // MARK: - View methods
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        //self.view.layoutIfNeeded()
        self.view.backgroundColor = Color.supportBackground.value
        self.view_header.backgroundColor = Color.supportHeaderBackground.value
        switch Device().diagonal {
        case 3.5:
            self.view_header.constraint(withIdentifier: "viewHeaderHeight", searchInSubviews: true)?.constant = 30
            self.img_top.constraint(withIdentifier: "imageHeight", searchInSubviews: false)?.constant = 130
        case 4:
            self.view_header.constraint(withIdentifier: "viewHeaderHeight", searchInSubviews: true)?.constant = 30
        case 4.7, 5.8:
            self.view_header.constraint(withIdentifier: "viewHeaderHeight", searchInSubviews: true)?.constant = 32
        //case 5.5:
        default:
            self.view_header.constraint(withIdentifier: "viewHeaderHeight", searchInSubviews: true)?.constant = 32
        //default:
        //    break
        }
        self.lbl_headerTitle.textColor = Color.supportHeaderLabel.value
        self.lbl_headerTitle.styledText = "lbl_supportHeaderTitle".localized().uppercased()
        self.lbl_title.textColor = Color.supportTitle.value
        self.lbl_title.styledText = "lbl_supportTitle".localized()
        self.lbl_subtitle.textColor = Color.supportSubtitle.value
        self.lbl_subtitle.styledText = "lbl_supportSubtitle".localized()
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
        // Buttons
        self.btn_call.style(.roundedButton(Color.supportCallBackgroundButton.value), title: "btn_supportCall".localized())
        self.btn_call.titleLabel?.font = FontWeight.bold.font(withSize: Font.roundedButton.getFontSize(size: 18))
        self.btn_call.rx.tap.asObservable()
            .subscribe(onNext:{
                guard let phoneCallURL = URL(string: "tel://" + "supportTelephoneNumber".localized()) else { return }
                if (UIApplication.shared.canOpenURL(phoneCallURL)) {
                    if #available(iOS 10.0, *) {
                        UIApplication.shared.open(phoneCallURL)
                    }
                    else
                    {
                        let message = "alert_supportCall".localized()
                        let dialog = ZAlertView(title: nil, message: message, isOkButtonLeft: false, okButtonText: "btn_supportAlertCall".localized(), cancelButtonText: "btn_cancel".localized(),
                                                okButtonHandler: { alertView in
                                                    alertView.dismissAlertView()
                                                    UIApplication.shared.openURL(phoneCallURL)
                        },
                                                cancelButtonHandler: { alertView in
                                                    alertView.dismissAlertView()
                        })
                        dialog.allowTouchOutsideToDismiss = false
                        dialog.show()
                    }
                } else {
                    let message = "alert_noSupportCall".localized()
                    let dialog = ZAlertView(title: nil, message: message, closeButtonText: "btn_ok".localized(), closeButtonHandler: { alertView in
                        alertView.dismissAlertView()
                    })
                    dialog.allowTouchOutsideToDismiss = false
                    dialog.show()
                }
            }).addDisposableTo(disposeBag)
    }
}
