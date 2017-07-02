//
//  Address.swift
//  Sharengo
//
//  Created by Dedecube on 31/05/17.
//  Copyright © 2017 Dedecube. All rights reserved.
//

import Boomerang
import RxSwift
import Gloss
import CoreLocation

public class FavouriteAddress: NSObject, NSCoding {
    var identifier: String?
    var name: String?
    var location: CLLocation?
    var address: String?
    
    init(identifier: String?, name: String?, location: CLLocation?, address: String?) {
        self.identifier = identifier
        self.name = name
        self.location = location
        self.address = address
    }
    
    // MARK: - Coding methods
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(self.identifier, forKey: "identifier")
        aCoder.encode(self.name, forKey: "name")
        aCoder.encode(self.location, forKey: "location")
        aCoder.encode(self.address, forKey: "address")
    }
    
    public required init?(coder aDecoder: NSCoder) {
        if let identifier = aDecoder.decodeObject(forKey: "identifier") as? String {
            self.identifier = identifier
        }
        if let name = aDecoder.decodeObject(forKey: "name") as? String {
            self.name = name
        }
        if let location = aDecoder.decodeObject(forKey: "location") as? CLLocation {
            self.location = location
        }
        if let address = aDecoder.decodeObject(forKey: "address") as? String {
            self.address = address
        }
    }
    
    // MARK: - Address methods
    
    func getAddress() -> Address {
        return Address(identifier: self.identifier, name: self.name, location: self.location, address: self.address)
    }
}

public class HistoryAddress: NSObject, NSCoding {
    var identifier: String?
    var name: String?
    var location: CLLocation?
    var address: String?
    
    init(identifier: String?, name: String?, location: CLLocation?, address: String?) {
        self.identifier = identifier
        self.name = name
        self.location = location
        self.address = address
    }
    
    // MARK: - Coding methods
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(self.identifier, forKey: "identifier")
        aCoder.encode(self.name, forKey: "name")
        aCoder.encode(self.location, forKey: "location")
        aCoder.encode(self.address, forKey: "address")
    }
    
    public required init?(coder aDecoder: NSCoder) {
        if let identifier = aDecoder.decodeObject(forKey: "identifier") as? String {
            self.identifier = identifier
        }
        if let name = aDecoder.decodeObject(forKey: "name") as? String {
            self.name = name
        }
        if let location = aDecoder.decodeObject(forKey: "location") as? CLLocation {
            self.location = location
        }
        if let address = aDecoder.decodeObject(forKey: "address") as? String {
            self.address = address
        }
    }
    
    // MARK: - Address methods
    
    func getAddress() -> Address {
        return Address(identifier: self.identifier, name: self.name, location: self.location, address: self.address)
    }
}

public class Address: ModelType, Decodable {
    /*
     JSON response example:
    {
        "place_id":"3325415",
        "licence":"Data © OpenStreetMap contributors, ODbL 1.0. http:\/\/www.openstreetmap.org\/copyright",
        "osm_type":"way",
        "osm_id":"176617221",
        "boundingbox":["43.5331996","43.5336263","10.3346801","10.3353129"],
        "lat":"43.5332977",
        "lon":"10.3353129",
        "display_name":"Via dei Pelaghi, Nuovo Centro, Salviano, Livorno, LI, TOS, 57127, Italia",
        "class":"highway",
        "type":"service",
        "importance":0.375
     }
    */
    
    var identifier: String?
    var name: String?
    var location: CLLocation?
    var address: String?
    
    static var empty:Address {
        return Address(identifier: nil, name: nil, location: nil, address: nil)
    }
    
    init(identifier: String?, name: String?, location: CLLocation?, address: String?) {
        self.identifier = identifier
        self.name = name
        self.location = location
        self.address = address
    }

    required public init?(json: JSON) {
        self.identifier = "place_id" <~~ json
        self.name = "display_name" <~~ json
        if let latitude: String = "lat" <~~ json, let longitude: String = "lon" <~~ json {
            if let lat: CLLocationDegrees = Double(latitude), let lon: CLLocationDegrees = Double(longitude) {
                self.location = CLLocation(latitude: lat, longitude: lon)
            }
        }
    }
    
    // MARK: - History methods
    
    func getHistoryAddress() -> HistoryAddress {
        return HistoryAddress(identifier: self.identifier, name: self.name, location: self.location, address: self.address)
    }
    
    // MARK: - Favourite methods
    
    func getFavouriteAddress() -> FavouriteAddress {
        return FavouriteAddress(identifier: self.identifier, name: self.name, location: self.location, address: self.address)
    }
}
