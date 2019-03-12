//
//  Address.swift
//  Sharengo
//
//  Created by Dedecube on 31/05/17.
//  Copyright © 2017 Dedecube. All rights reserved.
//


import RxSwift
import Gloss
import CoreLocation

/**
 The Favourite Address model is used to represent user's favourite addresses.
*/
public class FavouriteAddress: NSObject, NSCoding {
    /// Unique identifier
    public var identifier: String?
    /// Name that user used to remember this address
    public var name: String?
    /// Location of address
    public var location: CLLocation?
    /// Textual representation of address
    public var address: String?
    
    // MARK: - Init methods
    
    public init(identifier: String?, name: String?, location: CLLocation?, address: String?) {
        self.identifier = identifier
        self.name = name
        self.location = location
        self.address = address
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

    // MARK: - Coding methods
    
    /**
     This method is used to convert this object as NSCoder
     */
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(self.identifier, forKey: "identifier")
        aCoder.encode(self.name, forKey: "name")
        aCoder.encode(self.location, forKey: "location")
        aCoder.encode(self.address, forKey: "address")
    }
    
    // MARK: - Address methods
    
    /**
     This method is used to to get address of this favourite
     */
    public func getAddress() -> Address {
        return Address(identifier: self.identifier, name: self.name, location: self.location, address: self.address)
    }
}

/**
 The History Address model is used to represent historical addresses.
*/
public class HistoryAddress: NSObject, NSCoding {
    /// Unique identifier
    public var identifier: String?
    /// Name that user used to remember this address
    public var name: String?
    /// Location of address
    public var location: CLLocation?
    /// Textual representation of address
    public var address: String?
    
    // MARK: - Init methods
    
    public init(identifier: String?, name: String?, location: CLLocation?, address: String?) {
        self.identifier = identifier
        self.name = name
        self.location = location
        self.address = address
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

    // MARK: - Coding methods
    
    /**
     This method is used to convert this object as NSCoder
     */
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(self.identifier, forKey: "identifier")
        aCoder.encode(self.name, forKey: "name")
        aCoder.encode(self.location, forKey: "location")
        aCoder.encode(self.address, forKey: "address")
    }
    
    // MARK: - Address methods
    
    /**
     This method is used to get address of this historical address
     */
    func getAddress() -> Address {
        return Address(identifier: self.identifier, name: self.name, location: self.location, address: self.address)
    }
}

/**
 The Address model is used to represent an address.
*/
public class Address: ModelType, Gloss.JSONDecodable {
    /// Unique identifier
    public var identifier: String?
    /// Name that user used to remember this address
    public var name: String?
    /// Location of address
    public var location: CLLocation?
    /// Textual representation of address
    public var address: String?
    
    // MARK: - Init methods
    
    public init(identifier: String?, name: String?, location: CLLocation?, address: String?) {
        self.identifier = identifier
        self.name = name
        self.location = location
        self.address = address
    }

    required public init?(json: JSON) {
        self.identifier = "place_id" <~~ json
        self.name = "display_name" <~~ json
        self.address = "display_name" <~~ json
        if let latitude: String = "lat" <~~ json, let longitude: String = "lon" <~~ json {
            //if let latitude = Double(latitude), let longitude = Double(longitude){
            if let lat: CLLocationDegrees = Double(latitude), let lon: CLLocationDegrees = Double(longitude) {
                self.location = CLLocation(latitude: lat, longitude: lon)
            }
        }
    }
    
    // MARK: - History methods
    
    /**
     This method is used to get historical address
     */
    func getHistoryAddress() -> HistoryAddress {
        return HistoryAddress(identifier: self.identifier, name: self.name, location: self.location, address: self.address)
    }
    
    // MARK: - Favourite methods
    
    /**
     This method is used to get favourite address
     */
    func getFavouriteAddress() -> FavouriteAddress {
        return FavouriteAddress(identifier: self.identifier, name: self.name, location: self.location, address: self.address)
    }
}
