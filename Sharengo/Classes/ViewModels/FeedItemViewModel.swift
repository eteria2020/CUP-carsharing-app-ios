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
import KeychainSwift

/**
 The FeedViewModel provides data related to display content on feed collection view cell
 */
public class FeedItemViewModel : ItemViewModelType {
    /// ViewModel variable used to save data
    public var model:ItemViewModelType.Model
    /// ViewModel variable used to identify favourite item cell
    public var itemIdentifier:ListIdentifier = CollectionViewCell.feed
    /// Feed date
    public var date: String?
    /// Feed claim
    public var claim: String?
    /// Feed bottom text composed by date, subtitle, ...
    public var bottomText: String = ""
    /// Feed icon
    public var icon: String?
    /// Feed color
    public var color: UIColor
    /// Feed advantage color
    public var advantageColor: UIColor
    /// Feed image
    public var image: String?
    /// Variable used to save if the feed is a favourite item or not
    public var favourited = false
    
    // MARK: - Init methods
    
    public init(model: Feed) {
        self.model = model
        
        self.bottomText = ""
        
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
