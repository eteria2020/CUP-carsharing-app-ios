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
    
    var name: String?
    var location: CLLocation?
    
    static var empty:Address {
        return Address()
    }
    
    init() {
    }

    required public init?(json: JSON) {
        self.name = "display_name" <~~ json
        if let latitude: String = "lat" <~~ json, let longitude: String = "lon" <~~ json {
            if let lat: CLLocationDegrees = Double(latitude), let lon: CLLocationDegrees = Double(longitude) {
                self.location = CLLocation(latitude: lat, longitude: lon)
            }
        }
    }
}
