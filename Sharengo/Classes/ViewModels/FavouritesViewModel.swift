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
import KeychainSwift

/**
 Enum that specifies selection input
 */
public enum FavouritesSelectionInput: SelectionInput {
    case newFavourite
    case item(IndexPath)
}

/**
 Enum that specifies selection output
 */
public enum FavouritesSelectionOutput: SelectionOutput {
    case newFavourite
    case viewModel(ViewModelType)
    case empty
}

/**
 The Favourites model provides data related to display content on favourites in settings
 */
public class FavouritesViewModel: ListViewModelType, ViewModelTypeSelectable {
    fileprivate var resultsDispose: DisposeBag?
    /// ViewModel variable used to save data
    public var dataHolder: ListDataHolderType = ListDataHolder.empty
    /// Selection variable
    public lazy var selection:Action<FavouritesSelectionInput,FavouritesSelectionOutput> = Action { input in
        switch input {
        case .newFavourite:
            return .just(.newFavourite)
        default:
            return .just(.empty)
        }
    }

    // MARK: - ViewModel methods
    
    public func itemViewModel(fromModel model: ModelType) -> ItemViewModelType? {
        if let item = model as? Address {
            return ViewModelFactory.favouriteItem(fromModel: item)
        }
        return nil
    }
    
    // MARK: - Init methods
    
    public init() {
    }
    
    // MARK: - Update methods
    
    /**
     This method updates settings favourites
     */
    public func updateData() {
        var historyAndFavorites: [ModelType] = [ModelType]()
        if var dictionary = UserDefaults.standard.object(forKey: "favouritesAddressDic") as? [String: Data] {
            if let username = KeychainSwift().get("Username") {
                if let array = dictionary[username] {
                    if let unarchivedArray = NSKeyedUnarchiver.unarchiveObject(with: array) as? [FavouriteAddress] {
                        for historyAddress in Array(unarchivedArray) {
                            historyAndFavorites.append(historyAddress.getAddress())
                        }
                    }
                }
            }
        }
        if var dictionary = UserDefaults.standard.object(forKey: "historyDic") as? [String: Data] {
            if let username = KeychainSwift().get("Username") {
                if let array = dictionary[username] {
                    if let unarchivedArray = NSKeyedUnarchiver.unarchiveObject(with: array) as? [HistoryAddress] {
                        for historyAddress in Array(unarchivedArray) {
                            historyAndFavorites.append(historyAddress.getAddress())
                        }
                    }
                }
            }
        }
        self.dataHolder = ListDataHolder(data:Observable.just(historyAndFavorites).structured())
    }
}
