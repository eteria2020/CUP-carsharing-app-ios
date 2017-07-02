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

final class FavouriteItemViewModel : ItemViewModelType {
    var model:ItemViewModelType.Model
    var itemIdentifier:ListIdentifier = CollectionViewCell.favourite
    var title: String?
    var image: String?
    var favourite: Bool = false
    
    init(model: Address) {
        self.model = model
        self.title = String(format: "lbl_favouritesItemTitle2".localized(), model.name ?? "")
        self.image = "ic_location_search"
        self.favourite = false
        
        if let array = UserDefaults.standard.object(forKey: "historyArray") as? Data {
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
        if let array = UserDefaults.standard.object(forKey: "favouritesArray") as? Data {
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
