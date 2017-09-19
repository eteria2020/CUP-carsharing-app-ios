//
//  Feed.swift
//  Sharengo
//
//  Created by Dedecube on 12/07/17.
//  Copyright © 2017 Dedecube. All rights reserved.
//

import Boomerang
import RxSwift
import Gloss

/**
 The Favourite Feed model is used to represent user's favourite feeds.
 */
public class FavouriteFeed: NSObject, NSCoding {
    var identifier: String?
    var categoryTitle: String?
    var title: String?
    var subtitle: String?
    var ddescription: String?
    var icon: String?
    var claim: String?
    var date: String?
    var advantage: String?
    var color: String?
    var image: String?
    var location: String?
    var address: String?
    var city: String?
    var launchTitle: String?
    var forceColor: Bool = false
    var orderDate: Date = Date()
    var feedLocation: CLLocation?
    var marker: String?
    var sponsored: Bool = false
    
    init(identifier: String?, categoryTitle: String?, title: String?, subtitle: String?, ddescription: String?, icon: String?, claim: String?, date: String?, advantage: String?, color: String?, forceColor: Bool, image: String?, location: String?, address: String?, city: String?, launchTitle: String?, orderDate: Date, feedLocation: CLLocation?, marker: String?, sponsored: Bool) {
        self.identifier = identifier
        self.categoryTitle = categoryTitle
        self.title = title
        self.subtitle = subtitle
        self.ddescription = ddescription
        self.icon = icon
        self.claim = claim
        self.date = date
        self.advantage = advantage
        self.color = color
        self.forceColor = forceColor
        self.image = image
        self.location = location
        self.address = address
        self.city = city
        self.launchTitle = launchTitle
        self.orderDate = orderDate
        self.feedLocation = feedLocation
        self.marker = marker
        self.sponsored = sponsored
    }
    
    // MARK: - Coding methods
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(self.identifier, forKey: "identifier")
        aCoder.encode(self.categoryTitle, forKey: "categoryTitle")
        aCoder.encode(self.title, forKey: "title")
        aCoder.encode(self.subtitle, forKey: "subtitle")
        aCoder.encode(self.ddescription, forKey: "ddescription")
        aCoder.encode(self.icon, forKey: "icon")
        aCoder.encode(self.claim, forKey: "claim")
        aCoder.encode(self.date, forKey: "date")
        aCoder.encode(self.advantage, forKey: "advantage")
        aCoder.encode(self.color, forKey: "color")
        aCoder.encode(self.forceColor, forKey: "forceColor")
        aCoder.encode(self.image, forKey: "image")
        aCoder.encode(self.location, forKey: "location")
        aCoder.encode(self.address, forKey: "address")
        aCoder.encode(self.city, forKey: "city")
        aCoder.encode(self.launchTitle, forKey: "launchTitle")
        aCoder.encode(self.orderDate, forKey: "orderDate")
        aCoder.encode(self.feedLocation, forKey: "feedLocation")
        aCoder.encode(self.marker, forKey: "marker")
        aCoder.encode(self.sponsored, forKey: "sponsored")
    }
    
    public required init?(coder aDecoder: NSCoder) {
        if let identifier = aDecoder.decodeObject(forKey: "identifier") as? String {
            self.identifier = identifier
        }
        if let categoryTitle = aDecoder.decodeObject(forKey: "categoryTitle") as? String {
            self.categoryTitle = categoryTitle
        }
        if let title = aDecoder.decodeObject(forKey: "title") as? String {
            self.title = title
        }
        if let subtitle = aDecoder.decodeObject(forKey: "subtitle") as? String {
            self.subtitle = subtitle
        }
        if let ddescription = aDecoder.decodeObject(forKey: "ddescription") as? String {
            self.ddescription = ddescription
        }
        if let icon = aDecoder.decodeObject(forKey: "icon") as? String {
            self.icon = icon
        }
        if let claim = aDecoder.decodeObject(forKey: "claim") as? String {
            self.claim = claim
        }
        if let date = aDecoder.decodeObject(forKey: "date") as? String {
            self.date = date
        }
        if let advantage = aDecoder.decodeObject(forKey: "advantage") as? String {
            self.advantage = advantage
        }
        if let color = aDecoder.decodeObject(forKey: "color") as? String {
            self.color = color
        }
        if let image = aDecoder.decodeObject(forKey: "image") as? String {
            self.image = image
        }
        if let location = aDecoder.decodeObject(forKey: "location") as? String {
            self.location = location
        }
        if let address = aDecoder.decodeObject(forKey: "address") as? String {
            self.address = address
        }
        if let city = aDecoder.decodeObject(forKey: "city") as? String {
            self.city = city
        }
        if let launchTitle = aDecoder.decodeObject(forKey: "launchTitle") as? String {
            self.launchTitle = launchTitle
        }
        if let feedLocation = aDecoder.decodeObject(forKey: "feedLocation") as? CLLocation {
            self.feedLocation = feedLocation
        }
        if let marker = aDecoder.decodeObject(forKey: "marker") as? String {
            self.marker = marker
        }
        self.orderDate = aDecoder.decodeObject(forKey: "orderDate") as? Date ?? Date()
        self.forceColor = aDecoder.decodeBool(forKey: "forceColor")
        self.sponsored = aDecoder.decodeBool(forKey: "sponsored")
    }
    
    // MARK: - Feed methods
    
    func getFeed() -> Feed {
        return Feed(identifier: self.identifier, categoryTitle: self.categoryTitle, title: self.title, subtitle: self.subtitle, description: self.description, icon: self.icon, claim: self.claim, date: self.date, advantage: self.advantage, color: self.color, forceColor: self.forceColor, image: self.image, location: self.location, address: self.address, city: self.city, launchTitle: self.launchTitle, orderDate: self.orderDate, feedLocation: self.feedLocation, marker: self.marker, sponsored: self.sponsored)
    }
}

public class Feed: ModelType, Decodable {
    var identifier: String?
    var categoryTitle: String?
    var title: String?
    var subtitle: String?
    var description: String?
    var icon: String?
    var claim: String?
    var date: String?
    var orderDate: Date = Date()
    var advantage: String?
    var color: String?
    var image: String?
    var location: String?
    var address: String?
    var city: String?
    var launchTitle: String?
    var forceColor: Bool = false
    var feedLocation: CLLocation?
    var marker: String?
    var sponsored: Bool = false
    
    init(identifier: String?, categoryTitle: String?, title: String?, subtitle: String?, description: String?, icon: String?, claim: String?, date: String?, advantage: String?, color: String?, forceColor: Bool, image: String?, location: String?, address: String?, city: String?, launchTitle: String?, orderDate: Date, feedLocation: CLLocation?, marker: String?, sponsored: Bool) {
        self.identifier = identifier
        self.categoryTitle = categoryTitle
        self.title = title
        self.subtitle = subtitle
        self.description = description
        self.icon = icon
        self.claim = claim
        self.date = date
        self.advantage = advantage
        self.color = color
        self.forceColor = forceColor
        self.image = image
        self.location = location
        self.address = address
        self.city = city
        self.launchTitle = launchTitle
        self.orderDate = orderDate
        self.feedLocation = feedLocation
        self.marker = marker
        self.sponsored = sponsored
    }
    
    required public init?(json: JSON) {
        self.identifier = "nid" <~~ json ?? ""
        self.title = "title" <~~ json ?? ""
        self.subtitle = "informations.abstract" <~~ json ?? ""
        self.date = "informations.date.friendly" <~~ json ?? ""
        self.claim = "informations.advantage_top" <~~ json ?? ""
        self.advantage = "informations.advantage_bottom" <~~ json ?? ""
        self.description = "informations.description" <~~ json ?? ""
        self.categoryTitle = "category.name" <~~ json ?? ""
        self.icon = "category.media.images.icon.uri" <~~ json ?? ""
        self.image = "media.images.image.uri" <~~ json ?? ""
        self.location = "informations.location" <~~ json ?? ""
        self.address = "informations.address.friendly" <~~ json ?? ""
        self.city = "informations.city.name" <~~ json ?? ""
        self.launchTitle = "informations.launch_title" <~~ json ?? ""
        if let sponsored: String = "informations.sponsored" <~~ json {
            self.sponsored = sponsored.toBool() ?? false
        }
        if sponsored {
            self.marker = "media.images.icon.uri" <~~ json ?? ""
            self.color = "appearance.color.rgb" <~~ json ?? ""
        } else {
            self.marker = "category.media.images.marker.uri" <~~ json ?? ""
            self.color = "appearance.color.rgb_default" <~~ json ?? ""
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy HH:mm"
        self.orderDate = Decoder.decode(dateForKey: "informations.date.default", dateFormatter: dateFormatter)(json) ?? Date()
        if let latitude: String = "informations.address.lat" <~~ json, let longitude: String = "informations.address.lng" <~~ json {
            if let lat: CLLocationDegrees = Double(latitude), let lon: CLLocationDegrees = Double(longitude) {
                self.feedLocation = CLLocation(latitude: lat, longitude: lon)
            }
        }
        if let forceColor: String = "appearance.color.enforce" <~~ json {
            self.forceColor = forceColor.toBool() ?? false
        }
    
        self.title = self.title?.htmlDecoded()
        self.subtitle = self.subtitle?.htmlDecoded()
        self.claim = self.claim?.htmlDecoded()
        self.advantage = self.advantage?.htmlDecoded()
        self.description = self.description?.htmlDecoded()
        self.categoryTitle = self.categoryTitle?.htmlDecoded()
        self.location = self.location?.htmlDecoded()
        self.address = self.address?.htmlDecoded()
        self.city = self.city?.htmlDecoded()
        self.launchTitle = self.launchTitle?.htmlDecoded()
    }
    
    // MARK: - History methods
    
    func getFavoriteFeed() -> FavouriteFeed {
        return FavouriteFeed(identifier: self.identifier, categoryTitle: self.categoryTitle, title: self.title, subtitle: self.subtitle, ddescription: self.description, icon: self.icon, claim: self.claim, date: self.date, advantage: self.advantage, color: self.color, forceColor: self.forceColor, image: self.image, location: self.location, address: self.address, city: self.city, launchTitle: self.launchTitle, orderDate: self.orderDate, feedLocation: self.feedLocation, marker: self.marker, sponsored: self.sponsored)
    }
}
