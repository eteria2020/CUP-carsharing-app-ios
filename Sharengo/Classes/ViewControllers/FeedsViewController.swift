//
//  FeedsViewController.swift
//  Sharengo
//
//  Created by Dedecube on 12/07/17.
//  Copyright © 2017 Dedecube. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Boomerang
import SideMenu
import DeviceKit

class FeedsViewController : BaseViewController, ViewModelBindable, UICollectionViewDelegateFlowLayout {
    @IBOutlet fileprivate weak var view_navigationBar: NavigationBarView!
    @IBOutlet fileprivate weak var view_header: UIView!
    @IBOutlet fileprivate weak var btn_feed: UIButton!
    @IBOutlet fileprivate weak var view_bottomFeedButton: UIView!
    @IBOutlet fileprivate weak var btn_categories: UIButton!
    @IBOutlet fileprivate weak var view_bottomCategoriesButton: UIView!
    @IBOutlet fileprivate weak var collectionView: UICollectionView!
    @IBOutlet fileprivate weak var btn_aroundMe: UIButton!
    fileprivate var flow: UICollectionViewFlowLayout? {
        return self.collectionView?.collectionViewLayout as? UICollectionViewFlowLayout
    }
    
    var viewModel: FeedsViewModel?
    
    // MARK: - ViewModel methods
    
    func bind(to viewModel: ViewModelType?) {
        guard let viewModel = viewModel as? FeedsViewModel else {
            return
        }
        viewModel.selection.elements.subscribe(onNext:{ selection in
            switch selection {
            case .viewModel(let viewModel):
                Router.from(self,viewModel: viewModel).execute()
            default: break
            }
            self.dismiss(animated: true, completion: nil)
        }).addDisposableTo(self.disposeBag)
        self.viewModel = viewModel
        
        self.btn_aroundMe.rx.bind(to: viewModel.selection, input: .aroundMe)

        self.collectionView?.bind(to: viewModel)
        self.collectionView?.delegate = self
        
        self.viewModel?.reload()
    }
    
    // MARK: - View methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.view.layoutIfNeeded()
        // Views
        self.view_header.backgroundColor = Color.feedsHeaderBackground.value
        switch Device().diagonal {
        case 3.5:
            self.view_header.constraint(withIdentifier: "viewHeaderHeight", searchInSubviews: true)?.constant = 30
        case 4:
            self.view_header.constraint(withIdentifier: "viewHeaderHeight", searchInSubviews: true)?.constant = 30
        case 4.7:
            self.view_header.constraint(withIdentifier: "viewHeaderHeight", searchInSubviews: true)?.constant = 32
        case 5.5:
            self.view_header.constraint(withIdentifier: "viewHeaderHeight", searchInSubviews: true)?.constant = 32
        default:
            break
        }
        
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
        self.updateHeaderButtonsInterface()
        self.btn_feed.rx.tap.asObservable()
            .subscribe(onNext:{
                self.viewModel?.sectionSelected = .feed
                self.updateHeaderButtonsInterface()
                self.viewModel?.updateListDataHolder()
                self.viewModel?.reload()
                self.collectionView?.reloadData()
            }).addDisposableTo(disposeBag)
        self.btn_categories.rx.tap.asObservable()
            .subscribe(onNext:{
                self.viewModel?.sectionSelected = .categories
                self.updateHeaderButtonsInterface()
                self.viewModel?.updateListDataHolder()
                self.viewModel?.reload()
                self.collectionView?.reloadData()
            }).addDisposableTo(disposeBag)
        self.btn_aroundMe.style(.squaredButton(Color.feedsAroundMeButtonBackground.value), title: "btn_feedsAroundMe".localized())
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.viewModel?.reload()
        self.collectionView?.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    // MARK: - Collection methods
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if let viewModel = self.viewModel
        {
            switch viewModel.sectionSelected {
            case .feed:
                let size = collectionView.autosizeItemAt(indexPath: indexPath, itemsPerLine: 1)
                return CGSize(width: size.width, height: (UIScreen.main.bounds.height-(56+self.view_header.frame.size.height))/3)
            case .categories:
                let size = collectionView.autosizeItemAt(indexPath: indexPath, itemsPerLine: 2)
                return CGSize(width: size.width, height: (UIScreen.main.bounds.height-(56+self.view_header.frame.size.height))/3)
            }
        }
        
        // Default size
        let size = collectionView.autosizeItemAt(indexPath: indexPath, itemsPerLine: 1)
        return CGSize(width: size.width, height: (UIScreen.main.bounds.height-(56+self.view_header.frame.size.height))/3)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.viewModel?.selection.execute(.item(indexPath))
    }
    
    // MARK: - Header buttons methods
    
    func updateHeaderButtonsInterface()
    {
        if let viewModel = self.viewModel
        {
            switch viewModel.sectionSelected {
            case .feed:
                self.btn_feed.style(.headerButton(Font.feedsHeader.value, Color.feedsHeaderBackground.value, Color.feedsHeaderLabelOn.value), title: "btn_feedsHeaderFeed".localized())
                self.view_bottomFeedButton.backgroundColor = Color.feedsHeaderBottomButtonOn.value
                self.btn_categories.style(.headerButton(Font.feedsHeader.value, Color.feedsHeaderBackground.value, Color.feedsHeaderLabelOff.value), title: "btn_feedsHeaderCategories".localized())
                self.view_bottomCategoriesButton.backgroundColor = Color.feedsHeaderBottomButtonOff.value
            case .categories:
                self.btn_feed.style(.headerButton(Font.feedsHeader.value, Color.feedsHeaderBackground.value, Color.feedsHeaderLabelOff.value), title: "btn_feedsHeaderFeed".localized())
                self.view_bottomFeedButton.backgroundColor = Color.feedsHeaderBottomButtonOff.value
                self.btn_categories.style(.headerButton(Font.feedsHeader.value, Color.feedsHeaderBackground.value, Color.feedsHeaderLabelOn.value), title: "btn_feedsHeaderCategories".localized())
                self.view_bottomCategoriesButton.backgroundColor = Color.feedsHeaderBottomButtonOn.value
            }
        }
    }
}
