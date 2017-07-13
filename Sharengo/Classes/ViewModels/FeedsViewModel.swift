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

final class FeedsViewModel : ListViewModelType, ViewModelTypeSelectable {
    var dataHolder: ListDataHolderType = ListDataHolder.empty
    var feeds = [Feed]()
    fileprivate var resultsDispose: DisposeBag?
    
    lazy var selection:Action<FeedsSelectionInput,FeedsSelectionOutput> = Action { input in
        return .empty()
    }
    
    func itemViewModel(fromModel model: ModelType) -> ItemViewModelType? {
        if let item = model as? Feed {
            return ViewModelFactory.feedItem(fromModel: item)
        }
        return nil
    }
    
    init() {
        
        // Temp
        let feed = Feed()
        feed.claim = "claim"
        feed.color = "#b4ada7"
        feed.date = "date"
        feed.description = "description"
        feed.icon = "ic_assistenza"
        feed.identifier = "aaa"
        feed.image = "ic_assistenza"
        feed.subtitle = "subttiel"
        feed.title = "title"
        feed.advantage = "advantage"
        self.feeds = [feed, feed, feed]
        self.dataHolder = ListDataHolder(data:Observable.just(feeds).structured())

        self.selection = Action { input in
            switch input {
            case .item(let indexPath):
                return .just(.empty)
            case .aroundMe:
                return .just(.empty)
            }
        }
    }
}
