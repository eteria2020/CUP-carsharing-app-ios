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

enum FeedsSelectionInput : SelectionInput {
    case item(IndexPath)
    case aroundMe
}

enum FeedsSelectionOutput : SelectionOutput {
    case viewModel(ViewModelType)
    case empty
}

enum FeedSections {
    case feed
    case categories
}

final class FeedsViewModel : ListViewModelType, ViewModelTypeSelectable {
    var dataHolder: ListDataHolderType = ListDataHolder.empty
    var feeds = [Feed]()
    var categories = [Category]()
    var category: Category? = nil
    var sectionSelected = FeedSections.feed
    fileprivate var resultsDispose: DisposeBag?
    
    lazy var selection:Action<FeedsSelectionInput,FeedsSelectionOutput> = Action { input in
        return .empty()
    }
    
    func itemViewModel(fromModel model: ModelType) -> ItemViewModelType? {
        if let item = model as? Feed {
            return ViewModelFactory.feedItem(fromModel: item)
        }
        else if let item = model as? Category {
            return ViewModelFactory.categoryItem(fromModel: item)
        }
        return nil
    }
    
    init() {
        self.selection = Action { input in
            switch input {
            case .item(let indexPath):
                if let feed = self.model(atIndex: indexPath) as? Feed {
                    // TODO: aprire il dettaglio
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
                return .just(.empty)
            }
        }
    }
    
    func updateListDataHolder() {
        switch sectionSelected {
        case .feed:
            self.dataHolder = ListDataHolder(data:Observable.just(feeds).structured())
        case .categories:
            self.dataHolder = ListDataHolder(data:Observable.just(categories).structured())
        }
    }
}
