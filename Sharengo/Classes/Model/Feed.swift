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
    
    init(identifier: String?, categoryTitle: String?, title: String?, subtitle: String?, ddescription: String?, icon: String?, claim: String?, date: String?, advantage: String?, color: String?, forceColor: Bool, image: String?, location: String?, address: String?, city: String?, launchTitle: String?, orderDate: Date, feedLocation: CLLocation?, marker: String?) {
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
    }
    
    // MARK: - Feed methods
    
    func getFeed() -> Feed {
        return Feed(identifier: self.identifier, categoryTitle: self.categoryTitle, title: self.title, subtitle: self.subtitle, description: self.description, icon: self.icon, claim: self.claim, date: self.date, advantage: self.advantage, color: self.color, forceColor: self.forceColor, image: self.image, location: self.location, address: self.address, city: self.city, launchTitle: self.launchTitle, orderDate: self.orderDate, feedLocation: self.feedLocation, marker: self.marker)
    }
}

public class Feed: ModelType, Decodable {
    /*
    JSON response example:
    {
        "nid":"2",
        "title":"Offerta #2",
        "partner":
        {
            "tid":"4",
            "name":"Partner #2"
        },
        "category":
        {
            "tid":"1",
            "name":"Shopping",
            "media":
            {
                "images":
                {
                    "icon":
                    {
                        "uri":"http:\/\/universo-sharengo.thedigitalproject.it\/sites\/default\/files\/assets\/images\/icons\/sng-icona-shop-generica-100.png"
                    },
                    "marker":
                    {  
                        "uri":"http:\/\/universo-sharengo.thedigitalproject.it\/sites\/default\/files\/assets\/images\/markers\/puntatore-shop-generico_0.png"
                    }
                }
            }
        },
        "media":
        {
            "images":
            {
                "image":
                {
                    "uri":"http:\/\/universo-sharengo.thedigitalproject.it\/sites\/default\/files\/styles\/offers_events_640_340\/public\/assets\/images\/eventi-shop-sng-shopngo.jpg?itok=PH2laTNS"
                },
                "icon":
                {
                    "uri":"http:\/\/universo-sharengo.thedigitalproject.it\/sites\/default\/files\/assets\/images\/markers\/puntatore-shop-sng.png"
                }
            }
        },
        "appearance":
        {
            "color":
            {
                "rgb":"#954bb5",
                "enforce":"false"
            }
        },
        "informations":
        {
            "launch_title":"",
            "date":
            {
                "default":"31-07-2017 23:59",
                "friendly":"Luned\u00ec 31 Luglio 2017"
            },
            "city":
            {
                "tid":"5",
                "name":"Milano"
            },
            "location":"Sul piazzale",
            "address":
            {
                "friendly":"Piazzale Lagosta",
                "lat":"45.4892798",
                "lng":"9.191393100000028"
            },
            "advantage_top":"Nessun vantaggio TOP",
            "advantage_bottom":"Nessun vantaggio BOTTOM",
            "abstract":"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.",
            "description":"Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo. Nemo enim ipsam voluptatem quia voluptas sit aspernatur aut odit aut fugit, sed quia consequuntur magni dolores eos qui ratione voluptatem sequi nesciunt. Neque porro quisquam est, qui dolorem ipsum quia dolor sit amet, consectetur, adipisci velit, sed quia non numquam eius modi tempora incidunt ut labore et dolore magnam aliquam quaerat voluptatem. Ut enim ad minima veniam, quis nostrum exercitationem ullam corporis suscipit laboriosam, nisi ut aliquid ex ea commodi consequatur? Quis autem vel eum iure reprehenderit qui in ea voluptate velit esse quam nihil molestiae consequatur, vel illum qui dolorem eum fugiat quo voluptas nulla pariatur?"
            }
     }
    */
 
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
    
    init(identifier: String?, categoryTitle: String?, title: String?, subtitle: String?, description: String?, icon: String?, claim: String?, date: String?, advantage: String?, color: String?, forceColor: Bool, image: String?, location: String?, address: String?, city: String?, launchTitle: String?, orderDate: Date, feedLocation: CLLocation?, marker: String?) {
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
        self.color = "appearance.color.rgb" <~~ json ?? ""
        self.image = "media.images.image.uri" <~~ json ?? ""
        self.location = "informations.location" <~~ json ?? ""
        self.address = "informations.address.friendly" <~~ json ?? ""
        self.city = "informations.city.name" <~~ json ?? ""
        self.launchTitle = "informations.launch_title" <~~ json ?? ""
        self.marker = "category.media.images.marker.uri" <~~ json ?? ""
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
    }
    
    // MARK: - History methods
    
    func getFavoriteFeed() -> FavouriteFeed {
        return FavouriteFeed(identifier: self.identifier, categoryTitle: self.categoryTitle, title: self.title, subtitle: self.subtitle, ddescription: self.description, icon: self.icon, claim: self.claim, date: self.date, advantage: self.advantage, color: self.color, forceColor: self.forceColor, image: self.image, location: self.location, address: self.address, city: self.city, launchTitle: self.launchTitle, orderDate: self.orderDate, feedLocation: self.feedLocation, marker: self.marker)
    }
}
