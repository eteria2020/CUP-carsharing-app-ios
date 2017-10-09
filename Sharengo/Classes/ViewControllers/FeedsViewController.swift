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
import ReachabilitySwift

extension Date
{
    func isLessThanDate(_ dateToCompare: Date) -> Bool
    {
        var isLess = false
        
        if self.compare(dateToCompare) == ComparisonResult.orderedAscending
        {
            isLess = true
        }
        
        return isLess
    }
}

/**
 The Feeds class shows feeds
 */
public class FeedsViewController : BaseViewController, ViewModelBindable, UICollectionViewDelegateFlowLayout {
    @IBOutlet fileprivate weak var view_navigationBar: NavigationBarView!
    @IBOutlet fileprivate weak var view_headerCategory: UIView!
    @IBOutlet fileprivate weak var lbl_titleCategory: UILabel!
    @IBOutlet fileprivate weak var btn_backCategory: UIButton!
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
    
    fileprivate let publishersApiController: PublishersAPIController = PublishersAPIController()
    /// ViewModel variable used to represents the data
    public var viewModel: FeedsViewModel?
    var errorCategories: Bool?
    var errorOffers: Bool?
    var errorEvents: Bool?
    
    // MARK: - ViewModel methods
    
    public func bind(to viewModel: ViewModelType?) {
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
        
        self.showLoader()
        let dispatchTime = DispatchTime.now() + 0.1
        DispatchQueue.main.asyncAfter(deadline: dispatchTime) {
            if viewModel.category != nil
            {
                self.errorCategories = false
                self.publishersApiController.getOffers(category: viewModel.category!)
                    .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
                    .subscribe { event in
                        switch event {
                        case .next(let response):
                            if response.status_bool == true, let data = response.array_data {
                                if let feeds = [Feed].from(jsonArray: data) {
                                    let oldFeeds = self.viewModel?.feeds
                                    self.viewModel?.feeds = feeds
                                    self.viewModel?.feeds.append(contentsOf: oldFeeds ?? [])
                                    self.errorOffers = false
                                    self.checkData()
                                }
                            }
                        case .error(_):
                            self.errorOffers = true
                            self.checkData()
                        default:
                            break
                        }
                    }.addDisposableTo(self.disposeBag)
                self.publishersApiController.getEvents(category: viewModel.category!)
                    .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
                    .subscribe { event in
                        switch event {
                        case .next(let response):
                            if response.status_bool == true, let data = response.array_data {
                                if let feeds = [Feed].from(jsonArray: data) {
                                    self.viewModel?.feeds.append(contentsOf: feeds)
                                    self.errorEvents = false
                                    self.checkData()
                                }
                            }
                        case .error(_):
                            self.errorEvents = true
                            self.checkData()
                        default:
                            break
                        }
                    }.addDisposableTo(self.disposeBag)
            }
            else
            {
                self.publishersApiController.getCategories()
                    .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
                    .subscribe { event in
                        switch event {
                        case .next(let response):
                            if response.status_bool == true, let data = response.array_data {
                                if let categories = [Category].from(jsonArray: data) {
                                    self.viewModel?.categories = categories
                                    self.errorCategories = false
                                    self.checkData()
                                }
                            }
                        case .error(_):
                            self.errorCategories = true
                            self.checkData()
                        default:
                            break
                        }
                    }.addDisposableTo(self.disposeBag)
                self.publishersApiController.getOffers()
                    .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
                    .subscribe { event in
                        switch event {
                        case .next(let response):
                            if response.status_bool == true, let data = response.array_data {
                                if var feeds = [Feed].from(jsonArray: data) {
                                    feeds = feeds.sorted(by: { (order1, order2) -> Bool in
                                        return order1.orderDate.isLessThanDate(order2.orderDate)
                                    })
                                    let oldFeeds = self.viewModel?.feeds
                                    self.viewModel?.feeds = feeds
                                    self.viewModel?.feeds.append(contentsOf: oldFeeds ?? [])
                                    self.errorOffers = false
                                    self.checkData()
                                    return
                                }
                            }
                            self.errorOffers = false
                            self.checkData()
                            return
                        case .error(_):
                            self.errorOffers = true
                            self.checkData()
                        default:
                            break
                        }
                    }.addDisposableTo(self.disposeBag)
                self.publishersApiController.getEvents()
                    .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
                    .subscribe { event in
                        switch event {
                        case .next(let response):
                            if response.status_bool == true, let data = response.array_data {
                                if var feeds = [Feed].from(jsonArray: data) {
                                    feeds = feeds.sorted(by: { (order1, order2) -> Bool in
                                        return order1.orderDate.isLessThanDate(order2.orderDate)
                                    })
                                    self.viewModel?.feeds.append(contentsOf: feeds)
                                    self.errorEvents = false
                                    self.checkData()
                                    return
                                }
                            }
                            self.errorOffers = false
                            self.checkData()
                            return
                        case .error(_):
                            self.errorEvents = true
                            self.checkData()
                        default:
                            break
                        }
                    }.addDisposableTo(self.disposeBag)
            }
        }
    }
    
    /**
     This method is used to check data relative to feeds
     */
    public func checkData() {
        if self.errorCategories == false && self.errorEvents == false && self.errorOffers == false {
            DispatchQueue.main.async {[weak self]  in
                if self?.viewModel?.feeds.count == 0 {
                    let destination: NoFeedsViewController = (Storyboard.main.scene(.noFeeds))
                    destination.bind(to: ViewModelFactory.noFeeds(fromCategory: self?.viewModel?.category), afterLoad: true)
                    var array = self?.navigationController?.viewControllers ?? []
                    if self?.viewModel?.category != nil {
                        array.removeLast()
                    }
                    array.append(destination)
                    self?.navigationController?.viewControllers = array
                    self?.hideLoader(completionClosure: { () in
                       // let dispatchTime = DispatchTime.now() + 0.3
                       // DispatchQueue.main.asyncAfter(deadline: dispatchTime) {
                            self?.view.backgroundColor = Color.categoriesBackground.value
                            self?.viewModel?.sectionSelected = .categories
                            self?.updateHeaderButtonsInterface()
                            self?.viewModel?.updateListDataHolder()
                            self?.viewModel?.reload()
                            self?.collectionView?.reloadData()
                       // }
                    })
                    return
                }
                self?.viewModel?.updateListDataHolder()
                self?.viewModel?.reload()
                self?.collectionView?.reloadData()
                self?.hideLoader(completionClosure: { () in
                })
                if self?.viewModel?.category == nil {
                    self?.btn_aroundMe.isHidden = false
                }
            }
        } else if self.errorCategories == true || self.errorEvents == true || self.errorOffers == true {
            self.hideLoader(completionClosure: { () in
                var message = "alert_generalError".localized()
                if Reachability()?.isReachable == false {
                    message = "alert_connectionError".localized()
                }
                let dialog = ZAlertView(title: nil, message: message, closeButtonText: "btn_ok".localized(), closeButtonHandler: { alertView in
                    alertView.dismissAlertView()
                    Router.back(self)
                })
                dialog.allowTouchOutsideToDismiss = false
                dialog.show()
                
            })
        }
    }
    
    // MARK: - View methods
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        //self.view.layoutIfNeeded()
        // Views
        self.view.backgroundColor = ColorBrand.white.value
        self.btn_aroundMe.isHidden = true
        
        if self.viewModel?.category != nil
        {
            self.view_headerCategory.isHidden = false
            self.view_header.isHidden = true
            self.lbl_titleCategory.styledText = self.viewModel?.category?.title.uppercased()
            self.view_headerCategory.backgroundColor = Color.feedsHeaderCategoryBackground.value
            var headerCategoryHeight: Int = 0
            switch Device().diagonal {
            case 3.5:
                headerCategoryHeight = 30
            case 4:
                headerCategoryHeight = 30
            case 4.7:
                headerCategoryHeight = 32
            case 5.5:
                headerCategoryHeight = 32
            default:
                break
            }
            self.view_headerCategory.constraint(withIdentifier: "viewHeaderHeightCategory", searchInSubviews: true)?.constant = CGFloat(headerCategoryHeight)
            self.view_header.constraint(withIdentifier: "viewHeaderHeight", searchInSubviews: true)?.constant = CGFloat(headerCategoryHeight)
            self.btn_aroundMe.constraint(withIdentifier: "buttonHeight", searchInSubviews: false)?.constant = 0
        }
        else
        {
            self.view_headerCategory.isHidden = true
            self.view_header.isHidden = false
            self.view_header.backgroundColor = Color.feedsHeaderBackground.value
            switch Device().diagonal {
            case 3.5:
                self.view_header.constraint(withIdentifier: "viewHeaderHeight", searchInSubviews: true)?.constant = 43
                self.btn_aroundMe.constraint(withIdentifier: "buttonHeight", searchInSubviews: false)?.constant = 33
            case 4:
                self.view_header.constraint(withIdentifier: "viewHeaderHeight", searchInSubviews: true)?.constant = 46
                self.btn_aroundMe.constraint(withIdentifier: "buttonHeight", searchInSubviews: false)?.constant = 36
            case 4.7:
                self.view_header.constraint(withIdentifier: "viewHeaderHeight", searchInSubviews: true)?.constant = 48
                self.btn_aroundMe.constraint(withIdentifier: "buttonHeight", searchInSubviews: false)?.constant = 38
            case 5.5:
                self.view_header.constraint(withIdentifier: "viewHeaderHeight", searchInSubviews: true)?.constant = 48
                self.btn_aroundMe.constraint(withIdentifier: "buttonHeight", searchInSubviews: false)?.constant = 38
            default:
                break
            }
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
                self.view.backgroundColor = ColorBrand.white.value
                self.viewModel?.sectionSelected = .feed
                self.updateHeaderButtonsInterface()
                if self.viewModel?.feeds.count == 0 {
                    let destination: NoFeedsViewController = (Storyboard.main.scene(.noFeeds))
                    destination.bind(to: ViewModelFactory.noFeeds(fromCategory: self.viewModel?.category), afterLoad: true)
                    var array = self.navigationController?.viewControllers ?? []
                    if self.viewModel?.category != nil {
                        array.removeLast()
                    }
                    array.append(destination)
                    self.navigationController?.viewControllers = array
                    self.hideLoader(completionClosure: { () in
                    //let dispatchTime = DispatchTime.now() + 0.3
                    //DispatchQueue.main.asyncAfter(deadline: dispatchTime) {
                        self.view.backgroundColor = Color.categoriesBackground.value
                        self.viewModel?.sectionSelected = .categories
                        self.updateHeaderButtonsInterface()
                        self.viewModel?.updateListDataHolder()
                        self.viewModel?.reload()
                        self.collectionView?.reloadData()
                    //}
                    })
                    return
                }
                self.viewModel?.updateListDataHolder()
                self.viewModel?.reload()
                self.collectionView?.reloadData()
            }).addDisposableTo(disposeBag)
        self.btn_categories.rx.tap.asObservable()
            .subscribe(onNext:{
                self.view.backgroundColor = Color.categoriesBackground.value
                self.viewModel?.sectionSelected = .categories
                self.updateHeaderButtonsInterface()
                self.viewModel?.updateListDataHolder()
                self.viewModel?.reload()
                self.collectionView?.reloadData()
            }).addDisposableTo(disposeBag)
        self.btn_aroundMe.style(.squaredButton(Color.feedsAroundMeButtonBackground.value), title: "btn_feedsAroundMe".localized())
        self.btn_backCategory.setImage(self.btn_backCategory.image(for: .normal)?.tinted(UIColor.white), for: .normal)
        self.btn_backCategory.rx.tap.asObservable()
            .subscribe(onNext:{
                Router.back(self)
            }).addDisposableTo(disposeBag)
        
        // Labels
        self.lbl_titleCategory.textColor = Color.feedsHeaderCategoryLabel.value
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.viewModel?.reload()
        self.collectionView?.reloadData()
    }
    
    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    // MARK: - Collection methods
    
    /**
     This method is called from collection delegate to decide how the list interface is showed (line spacing)
     */
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    /**
     This method is called from collection delegate to decide how the list interface is showed (interitem spacing)
     */
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    /**
     This method is called from collection delegate to decide how the list interface is showed (inset)
     */
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.zero
    }
    
    /**
     This method is called from collection delegate to decide how the list interface is showed (size)
     */
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if let viewModel = self.viewModel
        {
            switch viewModel.sectionSelected {
            case .feed:
                let size = collectionView.autosizeItemAt(indexPath: indexPath, itemsPerLine: 1)
                return size
            case .categories:
                //let size = collectionView.autosizeItemAt(indexPath: indexPath, itemsPerLine: 2)
                let width = collectionView.bounds.size.width
                return CGSize(width: width, height: (UIScreen.main.bounds.height-(56+self.view_header.frame.size.height+self.btn_aroundMe.frame.size.height))/3)
            }
        }
        
        // Default size
        let size = collectionView.autosizeItemAt(indexPath: indexPath, itemsPerLine: 1)
        return size
    }
    
    /**
     This method is called from collection delegate when an option of the list is selected
     */
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.viewModel?.selection.execute(.item(indexPath))
    }
    
    // MARK: - Header buttons methods
    
    /**
     This method update header buttons interface based on section selected
     */
    public func updateHeaderButtonsInterface()
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
