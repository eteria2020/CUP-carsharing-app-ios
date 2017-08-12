//
//  City.swift
//  Sharengo
//
//  Created by Dedecube on 28/06/17.
//  Copyright © 2017 Dedecube. All rights reserved.
//

import Boomerang
import RxSwift
import Gloss

public class CityCache: NSObject, NSCoding {
    var identifier: String = ""
    var title: String = ""
    var icon: String = ""
    var selected = false
    var location: CLLocation?
    
    init(identifier: String, title: String, icon: String, selected: Bool, location: CLLocation?) {
        self.identifier = identifier
        self.title = title
        self.icon = icon
        self.selected = selected
        self.location = location
        if let url = URL(string: icon) {
            do {
                let data = try Data(contentsOf: url)
                let fileManager = FileManager.default
                let paths = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent(url.lastPathComponent)
                fileManager.createFile(atPath: paths as String, contents: data, attributes: nil)
            } catch { }
        }
    }
    
    // MARK: - Coding methods
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(self.identifier, forKey: "identifier")
        aCoder.encode(self.title, forKey: "title")
        aCoder.encode(self.icon, forKey: "icon")
        aCoder.encode(self.selected, forKey: "selected")
        aCoder.encode(self.location, forKey: "location")
    }
    
    public required init?(coder aDecoder: NSCoder) {
        if let identifier = aDecoder.decodeObject(forKey: "identifier") as? String {
            self.identifier = identifier
        }
        if let title = aDecoder.decodeObject(forKey: "title") as? String {
            self.title = title
        }
        if let icon = aDecoder.decodeObject(forKey: "icon") as? String {
            self.icon = icon
        }
        if let selected = aDecoder.decodeObject(forKey: "selected") as? Bool {
            self.selected = selected
        }
        if let location = aDecoder.decodeObject(forKey: "location") as? CLLocation {
            self.location = location
        }
    }
    
    // MARK: - City methods
    
    func getCity() -> City {
        return City(identifier: self.identifier, title: self.title, icon: self.icon, selected: self.selected, location: self.location)
    }
}

public class City: ModelType, Decodable {
    /*
    JSON response example:
    {
        "tid":"5",
        "name":"Milano",
        "media":
        {
            "images":
            {
                "icon":
                {
                    "uri":"http:\/\/universo-sharengo.thedigitalproject.it\/sites\/default\/files\/assets\/images\/icona_trasparente-milano.png"
                },
                "icon_svg":
                {
                    "uri":"http:\/\/universo-sharengo.thedigitalproject.it\/sites\/default\/files\/assets\/images\/icona_trasparente-milano.svg"
                }
            }
        },
        "informations":
        {
            "address":
            {
                "lat":"45.4628328",
                "lng":"9.1076928"
            }
        }
    }
    */
    
    var identifier: String = ""
    var title: String = ""
    var icon: String = ""
    var selected = false
    var location: CLLocation?
    
    init(identifier: String, title: String, icon: String, selected: Bool, location: CLLocation?) {
        self.identifier = identifier
        self.title = title
        self.icon = icon
        self.selected = selected
        self.location = location
    }
    
    required public init?(json: JSON) {
        self.identifier = "tid" <~~ json ?? ""
        self.title = "name" <~~ json ?? ""
        self.icon = "media.images.icon.uri" <~~ json ?? ""
        if let latitude: String = "informations.address.lat" <~~ json, let longitude: String = "informations.address.lng" <~~ json {
            if let lat: CLLocationDegrees = Double(latitude), let lon: CLLocationDegrees = Double(longitude) {
                self.location = CLLocation(latitude: lat, longitude: lon)
            }
        }
    }
    
    // MARK: - CityCache methods
    
    func getCityCache() -> CityCache {
        return CityCache(identifier: self.identifier, title: self.title, icon: self.icon, selected: self.selected, location: self.location)
    }
}
