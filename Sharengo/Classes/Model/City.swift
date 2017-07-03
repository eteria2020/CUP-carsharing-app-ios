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

public class City: ModelType, Decodable {
    /*
    {"tid":"5","name":"Milano","media":{"images":{"icon":{"uri":"http:\/\/universo-sharengo.thedigitalproject.it\/sites\/default\/files\/assets\/images\/icona_trasparente-milano.png"},"icon_svg":{"uri":"http:\/\/universo-sharengo.thedigitalproject.it\/sites\/default\/files\/assets\/images\/icona_trasparente-milano.svg"}}},"informations":{"address":{"lat":"45.4628328","lng":"9.1076928"}}}
    */
    
    var identifier: String = ""
    var title: String = ""
    var icon: String = ""
    var selected = false
    var location: CLLocation?
    
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
}
