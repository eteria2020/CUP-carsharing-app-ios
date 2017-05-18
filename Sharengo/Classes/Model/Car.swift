//
//  Car.swift
//  Sharengo
//
//  Created by Dedecube on 18/05/17.
//  Copyright © 2017 Dedecube. All rights reserved.
//

import Boomerang
import RxSwift

class Car : ModelType {
    var plate:String?
    
    static var empty:Car {
        return Car()
    }
    
    init(plate:String? = nil) {
        self.plate = plate
    }
}
