//
//  FeedsViewModel.swift
//  Sharengo
//
//  Created by Dedecube on 12/07/17.
//  Copyright © 2017 Dedecube. All rights reserved.
//

import Foundation
import RxSwift
import Boomerang
import Action
import KeychainSwift

/**
 Enum that specifies selection input
 */
public enum FeedsSelectionInput : SelectionInput {
    case item(IndexPath)
    case aroundMe
}

/**
 Enum that specifies selection output
 */
public enum FeedsSelectionOutput : SelectionOutput {
    case viewModel(ViewModelType)
    case empty
}

/**
 Enum that specifies feed sections
 */
public enum FeedSections {
    case feed
    case categories
}

/**
 The Feeds viewmodel provides data related to display content on FeedsVC
 */
public class FeedsViewModel : ListViewModelType, ViewModelTypeSelectable {
    public var dataHolder: ListDataHolderType = ListDataHolder.empty
    var feeds = [Feed]()
    var categories = [Category]()
    var category: Category? = nil
    var sectionSelected = FeedSections.feed
    fileprivate var resultsDispose: DisposeBag?
    /// Selection variable
    lazy public var selection:Action<FeedsSelectionInput,FeedsSelectionOutput> = Action { input in
        return .empty()
    }
    
    public func itemViewModel(fromModel model: ModelType) -> ItemViewModelType? {
        if let item = model as? Feed {
            return ViewModelFactory.feedItem(fromModel: item)
        }
        else if let item = model as? Category {
            return ViewModelFactory.categoryItem(fromModel: item)
        }
        return nil
    }
    
    // MARK: - Init methods
    
    public required init() {
        self.selection = Action { input in
            switch input {
            case .item(let indexPath):
                if let feed = self.model(atIndex: indexPath) as? Feed {
                    let feedDetailViewModel = ViewModelFactory.feedDetail(fromModel: feed)
                    return .just(.viewModel(feedDetailViewModel))
                } else if let category = self.model(atIndex: indexPath) as? Category {
                    if category.published
                    {
                        let feedsViewModel = ViewModelFactory.feeds()
                        (feedsViewModel as! FeedsViewModel).category = category
                        return .just(.viewModel(feedsViewModel))
                    }

                    let dialog = ZAlertView(title: nil, message: "alert_categoryNotPublished".localized(), closeButtonText: "btn_ok".localized(), closeButtonHandler: { alertView in
                        alertView.dismissAlertView()
                    })
                    dialog.allowTouchOutsideToDismiss = false
                    dialog.show()
                }
                return .just(.empty)
            case .aroundMe:
                return .just(.viewModel(ViewModelFactory.map(type: .feeds)))
            }
        }
    }
    
    // MARK: - Update methods
    
    /**
     This method update list data holder with feeds or categories based on selected section
     */
    public func updateListDataHolder() {
        switch sectionSelected {
        case .feed:
            self.dataHolder = ListDataHolder(data:Observable.just(feeds).structured())
        case .categories:
            self.dataHolder = ListDataHolder(data:Observable.just(categories).structured())
        }
    }
}
