//
//  CarBooking.swift
//  Sharengo
//
//  Created by Dedecube on 06/06/17.
//  Copyright © 2017 Dedecube. All rights reserved.
//

import Boomerang
import RxSwift
import Gloss

public class CarBooking: ModelType, Decodable {
    /*
     JSON response example:
    */
    
    // TODO: caricare i dati corretti
    
    var car: Car?
    var pin: String?
    var time: String?
    
    init(car: Car) {
        self.car = car
        self.pin = "1232"
        self.time = "52:22"
    }
    
    required public init?(json: JSON) {

    }
}
