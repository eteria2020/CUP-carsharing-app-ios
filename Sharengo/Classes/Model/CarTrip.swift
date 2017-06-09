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

public class CarTrip: ModelType, Decodable {
     /*
     JSON response example:
     {
        "id":1512138,
        "car_plate":"EH43413",
        "timestamp_start":1497018223,
        "timestamp_end":1497018373,
        "km_start":2226,
        "km_end":2226,
        "lat_start":"41.82672816666666",
        "lat_end":"41.826792833333336",
        "lon_start":"12.475439999999999",
        "lon_end":"12.475500833333335",
        "park_seconds":0
     }
     */
    
    var id: Int?
    var carPlate: String?
    var timeStart: Date?
    var timeEnd: Date?
    
    var car: Car?
    
    init(car: Car) {
        self.car = car
    }
    
    required public init?(json: JSON) {
        self.id = "id" <~~ json
        if let timestampStart: Double = "timestamp_start" <~~ json {
            self.timeStart = Date(timeIntervalSince1970: timestampStart)
        }
        if let timestampEnd: Double = "timestamp_start" <~~ json {
            self.timeEnd = Date(timeIntervalSince1970: timestampEnd)
        }
        if let carPlate: String = "car_plate" <~~ json {
            self.carPlate = carPlate
            CoreController.shared.apiController.searchCar(plate: carPlate)
                .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
                .subscribe { event in
                    switch event {
                    case .next(let response):
                        if response.status == 200, let data = response.dic_data {
                            self.car = Car(json: data)
                        }
                    default:
                        break
                    }
                }.addDisposableTo(CoreController.shared.disposeBag)
        }
    }
}
