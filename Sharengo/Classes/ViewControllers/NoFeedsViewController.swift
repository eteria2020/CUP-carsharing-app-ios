//
//  NoFeedsViewController.swift
//  Sharengo
//
//  Created by Dedecube on 16/07/17.
//  Copyright © 2017 Dedecube. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Boomerang
import SideMenu
import DeviceKit

class NoFeedsViewController : BaseViewController, ViewModelBindable {
    @IBOutlet fileprivate weak var view_navigationBar: NavigationBarView!
    @IBOutlet fileprivate weak var view_header: UIView!
    @IBOutlet fileprivate weak var lbl_title: UILabel!
    @IBOutlet fileprivate weak var btn_back: UIButton!
    @IBOutlet fileprivate weak var view_headerFeeds: UIView!
    @IBOutlet fileprivate weak var btn_feed: UIButton!
    @IBOutlet fileprivate weak var view_bottomFeedButton: UIView!
    @IBOutlet fileprivate weak var btn_categories: UIButton!
    @IBOutlet fileprivate weak var view_bottomCategoriesButton: UIView!
    @IBOutlet fileprivate weak var img_top: UIImageView!
    @IBOutlet fileprivate weak var lbl_description: UILabel!
    
    var viewModel: NoFeedsViewModel?
    
    // MARK: - ViewModel methods
    
    func bind(to viewModel: ViewModelType?) {
        guard let viewModel = viewModel as? NoFeedsViewModel else {
            return
        }
        viewModel.selection.elements.subscribe(onNext:{ selection in
            switch selection {
            default: break
            }
        }).addDisposableTo(self.disposeBag)
        
        self.viewModel = viewModel
        
        if self.viewModel?.category != nil
        {
            self.lbl_description.styledText = "lbl_noFeedsDescriptionWithCategory".localized()
        }
        else
        {
            self.lbl_description.styledText = "lbl_noFeedsDescriptionWithNoCategory".localized()
        }
    }
    
    // MARK: - View methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.view.layoutIfNeeded()
        self.view.backgroundColor = Color.noFeedsBackground.value
        self.view_header.backgroundColor = Color.noFeedsHeaderBackground.value
        self.view_headerFeeds.backgroundColor = Color.noFeedsFeedsHeaderBackground.value

        switch Device().diagonal {
        case 3.5:
            self.view_headerFeeds.constraint(withIdentifier: "viewHeaderFeedsHeight", searchInSubviews: true)?.constant = 43
            self.view_header.constraint(withIdentifier: "viewHeaderHeight", searchInSubviews: true)?.constant = 30
            self.img_top.constraint(withIdentifier: "imageHeight", searchInSubviews: false)?.constant = 130
        case 4:
            self.view_headerFeeds.constraint(withIdentifier: "viewHeaderFeedsHeight", searchInSubviews: true)?.constant = 46
            self.view_header.constraint(withIdentifier: "viewHeaderHeight", searchInSubviews: true)?.constant = 30
        case 4.7:
            self.view_headerFeeds.constraint(withIdentifier: "viewHeaderFeedsHeight", searchInSubviews: true)?.constant = 48
            self.view_header.constraint(withIdentifier: "viewHeaderHeight", searchInSubviews: true)?.constant = 32
        case 5.5:
            self.view_headerFeeds.constraint(withIdentifier: "viewHeaderFeedsHeight", searchInSubviews: true)?.constant = 48
            self.view_header.constraint(withIdentifier: "viewHeaderHeight", searchInSubviews: true)?.constant = 32
        default:
            break
        }
        
        self.lbl_title.textColor = Color.noFeedsHeaderLabel.value

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
        
        self.btn_feed.rx.tap.asObservable()
            .subscribe(onNext:{
            print("Feed")
        }).addDisposableTo(disposeBag)
        self.btn_categories.rx.tap.asObservable()
            .subscribe(onNext:{
            print("Categories")
        }).addDisposableTo(disposeBag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
}
