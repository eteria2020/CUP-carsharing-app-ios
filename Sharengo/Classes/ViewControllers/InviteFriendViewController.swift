//
//  InviteFriendViewController.swift
//  Sharengo
//
//  Created by Dedecube on 19/07/17.
//  Copyright © 2017 Dedecube. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

import SideMenu
import DeviceKit

/**
 The Invite friend class allows the user to invite a friend to sign up on Share'ngo
 */
public class InviteFriendViewController : BaseViewController, ViewModelBindable {
    @IBOutlet fileprivate weak var view_navigationBar: NavigationBarView!
    @IBOutlet fileprivate weak var view_header: UIView!
    @IBOutlet fileprivate weak var lbl_headerTitle: UILabel!
    @IBOutlet fileprivate weak var img_top: UIImageView!
    @IBOutlet fileprivate weak var lbl_descriptionFirstPart: UILabel!
    @IBOutlet fileprivate weak var lbl_descriptionSecondPart: UILabel!
    @IBOutlet fileprivate weak var lbl_descriptionThirdPart: UILabel!
    @IBOutlet fileprivate weak var lbl_descriptionFourthPart: UILabel!
    @IBOutlet fileprivate weak var view_firstSeparator: UIView!
    @IBOutlet fileprivate weak var view_secondSeparator: UIView!
    @IBOutlet fileprivate weak var view_thirdSeparator: UIView!
    @IBOutlet fileprivate weak var view_fourthSeparator: UIView!
    @IBOutlet fileprivate weak var btn_invite: UIButton!
    /// ViewModel variable used to represents the data
    public var viewModel: InviteFriendViewModel?
    
    // MARK: - ViewModel methods
    
    public func bind(to viewModel: ViewModelType?) {
        guard let viewModel = viewModel as? InviteFriendViewModel else {
            return
        }
        viewModel.selection.elements.subscribe(onNext:{ selection in
            switch selection {
            default: break
            }
        }).disposed(by: self.disposeBag)
        self.viewModel = viewModel
    }
    
    // MARK: - View methods
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        //self.view.layoutIfNeeded()
        self.view.backgroundColor = Color.inviteFriendBackground.value
        self.view_header.backgroundColor = Color.inviteFriendHeaderBackground.value
        switch Device().diagonal {
        case 3.5:
            self.view_header.constraint(withIdentifier: "viewHeaderHeight", searchInSubviews: true)?.constant = 30
            self.img_top.constraint(withIdentifier: "imageHeight", searchInSubviews: false)?.constant = 130
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
        self.lbl_headerTitle.textColor = Color.inviteFriendHeaderLabel.value
        self.lbl_headerTitle.styledText = "lbl_inviteFriendHeader".localized().uppercased()
        self.lbl_descriptionFirstPart.styledText = "lbl_inviteFriendDescriptionFirstPart".localized()
        self.lbl_descriptionSecondPart.styledText = "lbl_inviteFriendDescriptionSecondPart".localized()
        self.lbl_descriptionThirdPart.styledText = "lbl_inviteFriendDescriptionThirdPart".localized()
        self.lbl_descriptionFourthPart.styledText = "lbl_inviteFriendDescriptionFourthPart".localized()
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
        // Buttons
        self.btn_invite.style(.roundedButton(Color.inviteFriendInviteBackgroundButton.value), title: "btn_inviteFriendInvite".localized().uppercased())
        self.btn_invite.rx.tap.asObservable()
            .subscribe(onNext:{
                let textToShare = [ "lbl_inviteFriendInviteDescription".localized() ]
                let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
                self.present(activityViewController, animated: true, completion: nil)
            }).disposed(by: disposeBag)
    }
}
