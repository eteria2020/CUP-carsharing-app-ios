//
//  Car.swift
//  Sharengo
//
//  Created by Dedecube on 18/05/17.
//  Copyright © 2017 Dedecube. All rights reserved.
//

import Boomerang
import RxSwift
import Gloss
import CoreLocation

/**
 The Car model is used to represent a Car.
 */
public class Car: ModelType, Decodable {
    /// Car Plate
    public var plate: String?
    /// Duration of a trip
    public var capacity: Int?
    /// Location where Car is located
    public var location: CLLocation?
    /// Distance between User and Car
    public var distance: CLLocationDistance?
    /// Boolean that determine if car is the nearest from user
    public var nearest: Bool = false
    /// Boolean that determine if car is booked or not
    public var booked: Bool = false
    /// Boolean that determine if car is opened or not
    public var opened: Bool = false
    /// Boolean that determine if car is parked or not
    public var parking: Bool = false
    /// Type of car
    public lazy var type: String = self.getType()
    /// Address where Car is located
    public var address: Variable<String?> = Variable(nil)
    /// Array used to show if there are bonus with this car
    public var bonus: [Bonus] = []
    
    // MARK: - Init methods
    
    public init() {
    }
    
    public required init?(json: JSON) {
        self.plate = "plate" <~~ json
        self.capacity = "battery" <~~ json
        if let latitude: String = "lat" <~~ json, let longitude: String = "lon" <~~ json {
            if let lat: CLLocationDegrees = Double(latitude), let lon: CLLocationDegrees = Double(longitude) {
                self.location = CLLocation(latitude: lat, longitude: lon)
            }
        }
        if let latitude: String = "latitude" <~~ json, let longitude: String = "longitude" <~~ json {
            if let lat: CLLocationDegrees = Double(latitude), let lon: CLLocationDegrees = Double(longitude) {
                self.location = CLLocation(latitude: lat, longitude: lon)
            }
        }
        self.parking = "parking" <~~ json ?? false
        if let bonus = [Bonus].from(jsonArray: json["bonus"] as! [JSON]) {
            self.bonus = bonus
        }
    }
    
    // MARK: - Lazy methods
    
    /// Method that return typology of car
    public func getType() -> String {
        let bonusFree = self.bonus.filter({ (bonus) -> Bool in
            return bonus.type == "nouse" && bonus.status == true && bonus.value > 0
        })
        if bonusFree.count > 0 {
            return "lbl_carPopupFreeType".localized()
        } else if self.nearest {
           return "lbl_carPopupType".localized()
        } else {
            return ""
        }
    }
    
    // MARK: - Variable methods
    
    /// Method that return address of Car
    func getAddress() {
        if let location = self.location {
            let geocoder = CLGeocoder()
            geocoder.reverseGeocodeLocation(location, completionHandler: { placemarks, error in
                if let placemark = placemarks?.last {
                    if let thoroughfare = placemark.thoroughfare, let subthoroughfare = placemark.subThoroughfare, let locality = placemark.locality {
                        let address = "\(thoroughfare) \(subthoroughfare), \(locality)"
                        self.address.value = address
                    } else if let thoroughfare = placemark.thoroughfare, let locality = placemark.locality {
                        let address = "\(thoroughfare), \(locality)"
                        self.address.value = address
                    }
                }
            })
        }
    }
}
