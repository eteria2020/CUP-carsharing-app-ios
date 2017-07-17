//
//  FavouritesViewModel.swift
//  Sharengo
//
//  Created by Dedecube on 28/06/17.
//  Copyright © 2017 Dedecube. All rights reserved.
//

import Foundation
import RxSwift
import Boomerang
import Action

enum FavouritesSelectionInput: SelectionInput {
    case newFavourite
    case item(IndexPath)
}

enum FavouritesSelectionOutput: SelectionOutput {
    case newFavourite
    case viewModel(ViewModelType)
    case empty
}

final class FavouritesViewModel: ListViewModelType, ViewModelTypeSelectable {
    var dataHolder: ListDataHolderType = ListDataHolder.empty
    fileprivate var resultsDispose: DisposeBag?
   
    lazy var selection:Action<FavouritesSelectionInput,FavouritesSelectionOutput> = Action { input in
        switch input {
        case .newFavourite:
            return .just(.newFavourite)
        default:
            return .just(.empty)
        }
    }

    func itemViewModel(fromModel model: ModelType) -> ItemViewModelType? {
        if let item = model as? Address {
            return ViewModelFactory.favouriteItem(fromModel: item)
        }
        return nil
    }
    
    init() {
    }
    
    func updateData() {
        var historyAndFavorites: [ModelType] = [ModelType]()
        if let array = UserDefaults.standard.object(forKey: "favouritesAddressArray") as? Data {
            if let unarchivedArray = NSKeyedUnarchiver.unarchiveObject(with: array) as? [FavouriteAddress] {
                for historyAddress in Array(unarchivedArray) {
                    historyAndFavorites.append(historyAddress.getAddress())
                }
            }
        }
        if let array = UserDefaults.standard.object(forKey: "historyArray") as? Data {
            if let unarchivedArray = NSKeyedUnarchiver.unarchiveObject(with: array) as? [HistoryAddress] {
                for historyAddress in Array(unarchivedArray) {
                    historyAndFavorites.append(historyAddress.getAddress())
                }
            }
        }
        self.dataHolder = ListDataHolder(data:Observable.just(historyAndFavorites).structured())
    }
}
