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
 The Car model is used to represent a car.
 */
public class Car: ModelType, Decodable {
    /// Car plate
    public var plate: String?
    /// Car autonomy
    public var capacity: Int?
    /// Location where car is located
    public var location: CLLocation?
    /// Distance between user and car
    public var distance: CLLocationDistance?
    /// Boolean that determine if car is the nearest from user
    /// Boolean that determine if car is booked or not
    public var booked: Bool = false
    /// Boolean that determine if car is opened or not
    public var opened: Bool = false
    /// Boolean that determine if car is parked or not
    public var parking: Bool = false
    /// Address where car is located
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
    
    /**
     This method return typology of car
     */
    public func getType(carNearest: Car?) -> String {
        let bonusFree = self.bonus.filter({ (bonus) -> Bool in
            return bonus.type == "nouse" && bonus.status == true && bonus.value > 0
        })
        if bonusFree.count > 0 && self.plate == carNearest?.plate {
            let bonus = bonusFree[0]
            let string1 = "lbl_carPopupType".localized()
            let string2 = String(format: "lbl_carPopupFreeType".localized(), bonus.value)
            return "\(string1)\n\(string2)"
        } else if bonusFree.count > 0 {
            let bonus = bonusFree[0]
            return String(format: "lbl_carPopupFreeType".localized(), bonus.value)
        } else if self.plate == carNearest?.plate {
           return "lbl_carPopupType".localized()
        } else {
            return ""
        }
    }
    
    // MARK: - Variable methods
    
    /**
     This method return address of car
     */
    public func getAddress() {
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
