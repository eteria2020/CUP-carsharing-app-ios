//
//  FavouriteItemViewModel.swift
//  Sharengo
//
//  Created by Dedecube on 27/06/17.
//  Copyright © 2017 Dedecube. All rights reserved.
//

import Foundation
import RxSwift
import Boomerang
import KeychainSwift

/**
 The Favourite item model provides data related to display content on the favourite item
 */
public final class FavouriteItemViewModel : ItemViewModelType {
    /// ViewModel variable used to save data
    public var model:ItemViewModelType.Model
    /// ViewModel variable used to identify favourite item cell
    public var itemIdentifier:ListIdentifier = CollectionViewCell.favourite
    /// Title of the favourite item
    public var title: String?
    /// Image of the favourite item
    public var image: String?
    /// Variable used to save if the favourite item is really a favourite or a chronological address
    public var favourite: Bool = false
    
    // MARK: - Init methods
    
    public init(model: Address) {
        self.model = model
        self.title = String(format: "lbl_favouritesItemTitle2".localized(), model.name ?? "")
        self.image = "ic_location_search"
        self.favourite = false
        if var dictionary = UserDefaults.standard.object(forKey: "historyDic") as? [String: Data] {
            if let username = KeychainSwift().get("Username") {
                if let array = dictionary[username] {
                    if let unarchivedArray = NSKeyedUnarchiver.unarchiveObject(with: array) as? [HistoryAddress] {
                        let index = unarchivedArray.index(where: { (address) -> Bool in
                            return address.identifier == model.identifier
                        })
                        if index != nil {
                            self.title = String(format: "lbl_favouritesItemTitle2".localized(), model.name ?? "")
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
                            self.title = String(format: "lbl_favouritesItemTitle1".localized(), model.name ?? "", model.address ?? "")
                            self.image = "ic_favourites"
                            self.favourite = true
                        }
                    }
                }
            }
        }
    }
}
