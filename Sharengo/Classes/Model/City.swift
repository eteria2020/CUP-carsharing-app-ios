//
//  City.swift
//  Sharengo
//
//  Created by Dedecube on 28/06/17.
//  Copyright © 2017 Dedecube. All rights reserved.
//


import RxSwift
import Gloss

/**
 The CityCache  model is used to represent cache of a city.
*/
public class CityCache: NSObject, NSCoding {
    /// Unique identifier
    public var identifier: String = ""
    /// Title
    public var title: String = ""
    /// Icon
    public var icon: String = ""
    /// Boolean determine if selected or not
    public var selected = false
    /// Location of CityCache
    public var location: CLLocation?
    
    // MARK: - Init methods
    
    public init(identifier: String, title: String, icon: String, selected: Bool, location: CLLocation?) {
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
    
    // MARK: - Coding methods
    
    /**
     This method is used to convert this object as NSCoder
     */
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(self.identifier, forKey: "identifier")
        aCoder.encode(self.title, forKey: "title")
        aCoder.encode(self.icon, forKey: "icon")
        aCoder.encode(self.selected, forKey: "selected")
        aCoder.encode(self.location, forKey: "location")
    }

    // MARK: - City methods
    
    /**
     This method return City connected to CityCache
     */
    public func getCity() -> City {
        return City(identifier: self.identifier, title: self.title, icon: self.icon, selected: self.selected, location: self.location)
    }
}

/**
 The City  model is used to represent a city.
 */
public class City: ModelType, Gloss.Decodable {
    /// Unique identifier
    public var identifier: String = ""
    /// Title
    public var title: String = ""
    /// Icon
    public var icon: String = ""
    /// Boolean determine if selected or not
    public var selected = false
    /// Location of CityCache
    public var location: CLLocation?
    
    // MARK: - Init methods
    
    public init(identifier: String, title: String, icon: String, selected: Bool, location: CLLocation?) {
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
    
    /**
     This method return CityCache connected to City
     */
    func getCityCache() -> CityCache {
        return CityCache(identifier: self.identifier, title: self.title, icon: self.icon, selected: self.selected, location: self.location)
    }
}
