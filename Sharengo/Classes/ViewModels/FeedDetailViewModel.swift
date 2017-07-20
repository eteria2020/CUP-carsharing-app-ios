//
//  FeedDetailViewModel.swift
//  Sharengo
//
//  Created by Dedecube on 14/07/17.
//  Copyright © 2017 Dedecube. All rights reserved.
//

import Foundation
import RxSwift
import Boomerang
import Action
import KeychainSwift

final class FeedDetailViewModel: ViewModelType {
    var model:ItemViewModelType.Model
    var title: String?
    var date: String?
    var claim: String?
    var bottomText: String = ""
    var icon: String?
    var color: UIColor
    var advantageColor: UIColor
    var image: String?
    var favourited = false
    
    init(model: Feed) {
        self.model = model
        
        if model.launchTitle != nil && model.launchTitle?.isEmpty == false {
            self.bottomText.append("<title>\(model.launchTitle!.uppercased())</title>\n")
        }
        
        if model.date != nil && model.date?.isEmpty == false {
            self.bottomText.append("<date>\(model.date!)</date>\n")
        }
        
        if model.title != nil && model.title?.isEmpty == false {
            self.bottomText.append("<subtitle>\(model.title!)</subtitle>\n")
        }
        
        if model.subtitle != nil && model.subtitle?.isEmpty == false {
            self.bottomText.append("<description>\(model.subtitle!)</description>\n")
        }
        
        if model.location != nil && model.location?.isEmpty == false && model.address != nil && model.address?.isEmpty == false && model.city != nil && model.city?.isEmpty == false {
            self.bottomText.append("\n<description>\(model.location!), \(model.address!), \(model.city!)</description>")
        }
        
        if model.advantage != nil && model.advantage?.isEmpty == false {
            self.bottomText.append("\n<advantage>\(model.advantage!)</advantage>")
        }
        
        if model.description != nil && model.description?.isEmpty == false {
            self.bottomText.append("\n\n<extendedDescription>\(model.description!)</extendedDescription>")
        }
        
        self.title = model.categoryTitle?.uppercased()
        self.claim = model.claim
        self.icon = model.icon
        self.color = UIColor(hexString: model.color ?? "")
        self.image = model.image
        
        if model.forceColor {
            advantageColor = UIColor(hexString: model.color ?? "")
        } else {
            advantageColor = UIColor(hexString: "#888888")
        }
        
        if var dictionary = UserDefaults.standard.object(forKey: "favouritesFeedDic") as? [String: Data] {
            if let username = KeychainSwift().get("Username") {
                if let array = dictionary[username] {
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
    }
}
