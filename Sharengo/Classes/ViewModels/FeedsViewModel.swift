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

        self.selection = Action { input in
            switch input {
            case .item(let indexPath):
                guard let model = self.model(atIndex: indexPath) as?  Setting else { return .empty() }
                if let viewModel = model.viewModel  {
                    if viewModel is NoFavouritesViewModel {
                        var favourites: Bool = false
                        if let array = UserDefaults.standard.object(forKey: "favouritesArray") as? Data {
                            if let unarchivedArray = NSKeyedUnarchiver.unarchiveObject(with: array) as? [FavouriteAddress] {
                                if unarchivedArray.count > 0 {
                                    favourites = true
                                }
                            }
                        }
                        
                        if favourites {
                            return .just(.viewModel(ViewModelFactory.favourites()))
                        }
                    }
                    return .just(.viewModel(viewModel))
                }
                return .just(.empty)
            }
        }
    }
}
