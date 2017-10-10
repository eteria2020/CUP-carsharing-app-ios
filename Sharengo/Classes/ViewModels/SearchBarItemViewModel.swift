//
//  SearchBarItemViewModel.swift
//  Sharengo
//
//  Created by Dedecube on 02/06/17.
//  Copyright © 2017 Dedecube. All rights reserved.
//

import Foundation
import RxSwift
import Boomerang
import KeychainSwift

/**
 The SearchBarItemViewModel provides data related to display a single search result
 */
public class SearchBarItemViewModel : ItemViewModelType {
    public var model: ItemViewModelType.Model
    public var itemIdentifier: ListIdentifier = CollectionViewCell.searchBar
    /// Name that has to be displayed
    var name: String?
    /// Image that has to be displayed
    var image: String?
    
    // MARK: - Init methods
    
    public init(model: Address) {
        self.model = model
        self.name = model.name
        self.image = "ic_location_search"
        if var dictionary = UserDefaults.standard.object(forKey: "historyDic") as? [String: Data] {
            if let username = KeychainSwift().get("Username") {
                if let array = dictionary[username] {
                    if let unarchivedArray = NSKeyedUnarchiver.unarchiveObject(with: array) as? [HistoryAddress] {
                        let index = unarchivedArray.index(where: { (address) -> Bool in
                            return address.identifier == model.identifier
                        })
                        if index != nil {
                            self.image = "ic_clock"
                        }
                    }
                }
            }
        }
        if var dictionary = UserDefaults.standard.object(forKey: "favouritesAddressDic") as? [String: Data] {
            if let username = KeychainSwift().get("Username") {
                if let array = dictionary[username] {
                    if let unarchivedArray = NSKeyedUnarchiver.unarchiveObject(with: array) as? [FavouriteAddress] {
                        let index = unarchivedArray.index(where: { (address) -> Bool in
                            return address.identifier == model.identifier
                        })
                        if index != nil {
                            self.image = "ic_favourites"
                        }
                    }
                }
            }
        }
    }
    
    public init(model: Car) {
        self.model = model
        self.name = String(format: "lbl_searchBarPlate".localized(), model.plate ?? "")
        self.image = "ic_targa_ricerca"
    }
    
    public init(model: Favorite) {
        self.model = model
        self.name = model.name
        if self.name != "lbl_favouritesNoFavorites".localized() {
            self.image = "ic_favourites"
        }
    }
}
