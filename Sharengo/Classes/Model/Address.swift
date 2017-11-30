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

/**
 The Favourite Address model is used to represent user's favourite addresses
*/
public class FavouriteAddress: NSObject, NSCoding {
    /// Unique identifier of address
    public var identifier: String?
    /// Name of the address
    public var name: String?
    /// Location of the address
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
    
    /**
     This method is used to convert this object from NSCoder
     */
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
     This method is used to to get Address object from this favourite
     */
    public func getAddress() -> Address {
        return Address(identifier: self.identifier, name: self.name, location: self.location, address: self.address)
    }
}

/**
 The History Address model is used to represent addresses searched from user.
*/
public class HistoryAddress: NSObject, NSCoding {
    /// Unique identifier of address
    public var identifier: String?
    /// Name of the address
    public var name: String?
    /// Location of the address
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
    
    /**
     This method is used to convert this object from NSCoder
     */
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
     This method is used to to get Address object from this history address
     */
    func getAddress() -> Address {
        return Address(identifier: self.identifier, name: self.name, location: self.location, address: self.address)
    }
}

/**
 The Address model is used to represent an address.
*/
public class Address: ModelType, Decodable {
    /// Unique identifier of address
    public var identifier: String?
    /// Name of the address
    public var name: String?
    /// Location of the address
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
        self.name = "formatted_address" <~~ json
        if let latitude: Double = "geometry.location.lat" <~~ json, let longitude: Double = "geometry.location.lng" <~~ json {
            self.location = CLLocation(latitude: latitude, longitude: longitude)
        }
    }
    
    // MARK: - History methods
    
    /**
     This method is used to get history address
     */
    public func getHistoryAddress() -> HistoryAddress {
        return HistoryAddress(identifier: self.identifier, name: self.name, location: self.location, address: self.address)
    }
    
    // MARK: - Favourite methods
    
    /**
     This method is used to get favourite address
     */
    public func getFavouriteAddress() -> FavouriteAddress {
        return FavouriteAddress(identifier: self.identifier, name: self.name, location: self.location, address: self.address)
    }
}
