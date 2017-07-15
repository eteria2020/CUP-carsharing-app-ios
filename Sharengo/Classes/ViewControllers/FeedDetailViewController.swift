//
//  FeedDetailViewController.swift
//  Sharengo
//
//  Created by Dedecube on 14/07/17.
//  Copyright © 2017 Dedecube. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Boomerang
import SideMenu
import DeviceKit
import BonMot

class FeedDetailViewController : BaseViewController, ViewModelBindable {
    @IBOutlet fileprivate weak var view_navigationBar: NavigationBarView!
    @IBOutlet fileprivate weak var view_header: UIView!
    @IBOutlet fileprivate weak var lbl_title: UILabel!
    @IBOutlet fileprivate weak var btn_back: UIButton!
    @IBOutlet fileprivate weak var scrollview_main: UIScrollView!
    @IBOutlet fileprivate weak var view_scrollViewContainer: UIView!
    @IBOutlet fileprivate weak var view_containerBackgroundImage: UIView!
    @IBOutlet fileprivate weak var img_background: UIImageView!
    @IBOutlet fileprivate weak var view_overlayBackgroundImage: UIView!
    @IBOutlet fileprivate weak var view_containerClaim: UIView!
    @IBOutlet fileprivate weak var lbl_claim: UILabel!
    @IBOutlet fileprivate weak var img_claim: UIImageView!
    @IBOutlet fileprivate weak var view_bottomContainer: UIView!
    @IBOutlet fileprivate weak var lbl_bottom: UILabel!
    @IBOutlet fileprivate weak var img_icon: UIImageView!
    @IBOutlet fileprivate weak var view_icon: UIView!
    @IBOutlet fileprivate weak var btn_favourite: UIButton!

    var viewModel: FeedDetailViewModel?
    var favourited = false
    
    // MARK: - ViewModel methods
    
    func bind(to viewModel: ViewModelType?) {
        guard let viewModel = viewModel as? FeedDetailViewModel else {
            return
        }
        self.viewModel = viewModel
        
        self.viewModel = viewModel
        
        if viewModel.claim != nil && viewModel.claim?.isEmpty == false
        {
            self.view_containerClaim.isHidden = false
            self.lbl_claim.styledText = viewModel.claim
            self.img_claim.image = self.img_claim.image?.tinted(viewModel.color)
        }
        else
        {
            self.view_containerClaim.isHidden = true
        }
        
        if let icon = viewModel.icon,
            let url = URL(string: icon)
        {
            do {
                let data = try Data(contentsOf: url)
                if let image = UIImage(data: data) {
                    self.img_icon.image = image.tinted(Color.feedsItemIconBorderBackground.value)
                }
            } catch {
            }
        }
        
        if let image = viewModel.image,
            let url = URL(string: image)
        {
            do {
                let data = try Data(contentsOf: url)
                if let image = UIImage(data: data) {
                    self.img_background.image = image
                }
            } catch {
            }
        }
        
        self.view_overlayBackgroundImage.backgroundColor = viewModel.color.withAlphaComponent(0.5)
        
        self.lbl_title.styledText = viewModel.title

        let titleStyle = StringStyle(.font(Font.feedsItemTitle.value), .color(viewModel.color), .alignment(.left))
        let dateStyle = StringStyle(.font(Font.feedsItemDate.value), .color(Color.feedsItemDate.value), .alignment(.left))
        let subtitleStyle = StringStyle(.font(Font.feedsItemSubtitle.value), .color(Color.feedsItemSubtitle.value), .alignment(.left))
        let descriptionStyle = StringStyle(.font(Font.feedsItemDescription.value), .color(Color.feedsItemDescription.value), .alignment(.left))
        let advantageStyle = StringStyle(.font(Font.feedsItemAdvantage.value), .color(viewModel.advantageColor), .alignment(.left))
        let extendedDescriptionStyle = StringStyle(.font(Font.feedExtendedDescription.value), .color(Color.feedExtendedDescription.value), .alignment(.left))
        
        self.lbl_bottom.bonMotStyle = StringStyle(.font(Font.feedsItemDescription.value), .color(Color.feedsItemDescription.value), .alignment(.center),.xmlRules([.style("title", titleStyle), .style("date", dateStyle), .style("subtitle", subtitleStyle), .style("description", descriptionStyle), .style("advantage", advantageStyle), .style("extendedDescription", extendedDescriptionStyle)]))
        self.lbl_bottom.styledText = viewModel.bottomText
        
        self.view_icon.backgroundColor = viewModel.color
    }
    
    // MARK: - View methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.layoutIfNeeded()
        
        // Views
        self.view_header.backgroundColor = Color.settingsCitiesHeaderBackground.value

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
        
        // Buttons
        self.btn_back.setImage(self.btn_back.image(for: .normal)?.tinted(UIColor.white), for: .normal)
        self.btn_back.rx.tap.asObservable()
            .subscribe(onNext:{
                Router.back(self)
            }).addDisposableTo(disposeBag)
        self.btn_favourite.style(.roundedButton(Color.alertButtonsPositiveBackground.value), title: "btn_feedDetailFavourite".localized())
        self.btn_favourite.rx.tap.asObservable()
            .subscribe(onNext:{
                if self.favourited
                {
                    self.favourited = false
                    self.btn_favourite.styledText = "btn_feedDetailFavourite".localized()
                }
                else
                {
                    self.favourited = true
                    self.btn_favourite.styledText = "btn_feedDetailNotFavourite".localized()
                }
            }).addDisposableTo(disposeBag)
        
        // Labels
        self.lbl_title.textColor = Color.settingsCitiesHeaderLabel.value
        
        // Images
        self.view_icon.layer.cornerRadius = self.view_icon.frame.size.width/2
        self.view_icon.layer.masksToBounds = true
        self.view_icon.layer.borderWidth = 1
        self.view_icon.layer.borderColor = Color.feedsItemIconBorderBackground.value.cgColor

        switch Device().diagonal {
        case 3.5:
            self.view_header.constraint(withIdentifier: "viewHeaderHeight", searchInSubviews: true)?.constant = 30
            self.btn_favourite.constraint(withIdentifier: "buttonHeight", searchInSubviews: false)?.constant = 33
        case 4:
            self.view_header.constraint(withIdentifier: "viewHeaderHeight", searchInSubviews: true)?.constant = 30
            self.btn_favourite.constraint(withIdentifier: "buttonHeight", searchInSubviews: false)?.constant = 36
        case 4.7:
            self.view_header.constraint(withIdentifier: "viewHeaderHeight", searchInSubviews: true)?.constant = 32
            self.btn_favourite.constraint(withIdentifier: "buttonHeight", searchInSubviews: false)?.constant = 38
        case 5.5:
            self.view_header.constraint(withIdentifier: "viewHeaderHeight", searchInSubviews: true)?.constant = 32
            self.btn_favourite.constraint(withIdentifier: "buttonHeight", searchInSubviews: false)?.constant = 38
        default:
            break
        }
    }
}
