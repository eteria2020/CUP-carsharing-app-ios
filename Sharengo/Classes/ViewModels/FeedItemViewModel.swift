//
//  FeedItemViewModel.swift
//  Sharengo
//
//  Created by Dedecube on 12/07/17.
//  Copyright © 2017 Dedecube. All rights reserved.
//

import Foundation
import RxSwift
import Boomerang

final class FeedItemViewModel : ItemViewModelType {
    var model:ItemViewModelType.Model
    var itemIdentifier:ListIdentifier = CollectionViewCell.feed
    var date: String?
    var claim: String?
    var bottomText: String?
    var icon: String?
    var color: UIColor
    var advantageColor: UIColor
    var image: String?
    var favourited = false
    
    init(model: Feed) {
        self.model = model
        
        if model.advantage != nil && model.advantage?.isEmpty == false
        {
            self.bottomText = String(format: "lbl_feedsItemExtendedBottom".localized(), model.launchTitle?.uppercased() ?? "", model.date ?? "", model.title ?? "", model.subtitle ?? "", model.location ?? "", model.address ?? "", model.city ?? "", model.advantage!)
        }
        else
        {
            self.bottomText = String(format: "lbl_feedsItemBottom".localized(), model.launchTitle?.uppercased() ?? "", model.date ?? "", model.title ?? "", model.subtitle ?? "", model.location ?? "", model.address ?? "", model.city ?? "")
        }
        
        self.claim = model.claim
        self.icon = model.icon
        self.color = UIColor(hexString: model.color ?? "")
        self.image = model.image
        
        if model.forceColor {
            advantageColor = UIColor(hexString: model.color ?? "")
        } else {
            advantageColor = UIColor(hexString: "#888888")
        }
   
        if let array = UserDefaults.standard.object(forKey: "favouritesFeedArray") as? Data {
            if let unarchivedArray = NSKeyedUnarchiver.unarchiveObject(with: array) as? [FavouriteFeed] {
                let index = unarchivedArray.index(where: { (feed) -> Bool in
                    return feed.identifier == model.identifier
                })
                if index != nil {
                    self.favourited = true
                }
            }
        }
    }
}
