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
import pop
import KeychainSwift

/**
 The Feed Detail class show feed content in a viewcontroller
 */
public class FeedDetailViewController : BaseViewController, ViewModelBindable {
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
    @IBOutlet fileprivate weak var img_favorite: UIImageView!
    @IBOutlet fileprivate weak var view_icon: UIView!
    @IBOutlet fileprivate weak var btn_favourite: UIButton!
    /// ViewModel variable used to represents the data
    public var viewModel: FeedDetailViewModel?
    
    // MARK: - ViewModel methods
    
    public func bind(to viewModel: ViewModelType?) {
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
        
        self.view_containerBackgroundImage.backgroundColor = viewModel.color
        
        self.img_background.alpha = 0.0
        DispatchQueue.global(qos: .background).async {
            if let image = viewModel.image,
                let url = URL(string: image)
            {
                do {
                    let data = try Data(contentsOf: url)
                    if let image = UIImage(data: data) {
                        DispatchQueue.main.async {
                            self.img_background.image = image
                            UIView.animate(withDuration: 0.25, animations: {
                                self.img_background.alpha = 1.0
                           })
                        }
                    }
                } catch {
                }
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
        
        if viewModel.favourited
        {
            self.img_favorite.alpha = 1.0
            self.btn_favourite.style(.roundedButton(Color.alertButtonsPositiveBackground.value), title: "btn_feedDetailNotFavourite".localized())
        }
        else
        {
            self.img_favorite.alpha = 0.0
            self.btn_favourite.style(.roundedButton(Color.alertButtonsPositiveBackground.value), title: "btn_feedDetailFavourite".localized())
        }
        self.btn_favourite.rx.tap.asObservable()
            .subscribe(onNext:{
                if viewModel.favourited
                {
                    let popAnimation1: POPBasicAnimation = POPBasicAnimation(propertyNamed: kPOPViewAlpha)
                    popAnimation1.fromValue = 1
                    popAnimation1.toValue = 0
                    popAnimation1.duration = 0.5
                    self.img_favorite.pop_add(popAnimation1, forKey: "popAnimation1")
                    
                    viewModel.favourited = false
                    self.btn_favourite.style(.roundedButton(Color.alertButtonsPositiveBackground.value), title: "btn_feedDetailFavourite".localized())
                    
                    if var dictionary = UserDefaults.standard.object(forKey: "favouritesFeedDic") as? [String: Data] {
                        if let username = KeychainSwift().get("Username") {
                            if let array = dictionary[username] {
                                if var unarchivedArray = NSKeyedUnarchiver.unarchiveObject(with: array) as? [FavouriteFeed] {
                                    let index = unarchivedArray.index(where: { (feed) -> Bool in
                                        return feed.identifier == (viewModel.model as! Feed).identifier
                                    })
                                    if index != nil {
                                        unarchivedArray.remove(at: index!)
                                    }
                                    let archivedArray = NSKeyedArchiver.archivedData(withRootObject: unarchivedArray as Array)
                                    dictionary[username] = archivedArray
                                    UserDefaults.standard.set(dictionary, forKey: "favouritesFeedDic")
                                }
                            }
                        }
                    }
                }
                else
                {
                    let popAnimation1: POPBasicAnimation = POPBasicAnimation(propertyNamed: kPOPViewAlpha)
                    popAnimation1.fromValue = 0
                    popAnimation1.toValue = 1
                    popAnimation1.duration = 0.5
                    let popAnimation2: POPBasicAnimation = POPBasicAnimation(propertyNamed: kPOPViewScaleXY)
                    popAnimation2.fromValue = NSValue(cgSize: CGSize(width: 0.5, height: 0.5))
                    popAnimation2.toValue = NSValue(cgSize: CGSize(width: 1, height: 1))
                    popAnimation2.duration = 0.5
                    self.img_favorite.pop_add(popAnimation1, forKey: "popAnimation1")
                    self.img_favorite.pop_add(popAnimation2, forKey: "popAnimation2")
                    
                    viewModel.favourited = true
                    self.btn_favourite.style(.roundedButton(Color.alertButtonsPositiveBackground.value), title: "btn_feedDetailNotFavourite".localized())
                
                    if var dictionary = UserDefaults.standard.object(forKey: "favouritesFeedDic") as? [String: Data] {
                        if let username = KeychainSwift().get("Username") {
                            if let array = dictionary[username] {
                                if var unarchivedArray = NSKeyedUnarchiver.unarchiveObject(with: array) as? [FavouriteFeed] {
                                    unarchivedArray.insert((viewModel.model as! Feed).getFavoriteFeed(), at: 0)
                                    let archivedArray = NSKeyedArchiver.archivedData(withRootObject: unarchivedArray as Array)
                                    dictionary[username] = archivedArray
                                    UserDefaults.standard.set(dictionary, forKey: "favouritesFeedDic")
                                }
                            }
                        }
                    }
                }
            }).addDisposableTo(disposeBag)
    }
    
    // MARK: - View methods
    
    override public func viewDidLoad() {
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
