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
     {
        "id":1679899,
        "reservation_timestamp":1496780744,
        "timestamp_start":1496780744,
        "is_active":true,
        "car_plate":"EF72806",
        "length":1200
     }
     */
    
    var id: Int?
    var isActive: Bool = false
    var carPlate: String?
    var timeStart: Date?
    var timeLength: Int = 1200
    
    var car: Variable<Car?> = Variable(nil)
  
    var time: String? {
        get {
            if let timeStart = self.timeStart {
                let start = timeStart
                let enddt = Date()
                let calendar = Calendar.current
                let datecomponenets = calendar.dateComponents([Calendar.Component.second], from: start, to: enddt)
                if let seconds = datecomponenets.second {
                    let min = (Float(timeLength-seconds) / 60).rounded(.towardZero)
                    let sec = Float(timeLength-seconds).truncatingRemainder(dividingBy: 60)
                    if min <= 0 && sec <= 0 {
                        return "<bold>00:00</bold> \("lbl_carBookingPopupTimeMinutes".localized())"
                    }
                    let m = (min < 10) ? "0\(Int(min))" : "\(Int(min))"
                    let s = (sec < 10) ? "0\(Int(sec))" : "\(Int(sec))"
                    return "<bold>\(m):\(s)</bold> \("lbl_carBookingPopupTimeMinutes".localized())"
                }
            }
            return nil
        }
    }

    init(car: Car) {
        self.car.value = car
    }
    
    required public init?(json: JSON) {
        self.id = "id" <~~ json
        self.isActive = "is_active" <~~ json ?? false
        self.timeLength = "length" <~~ json ?? 1200
        if let timestamp: Double = "reservation_timestamp" <~~ json {
            self.timeStart = Date(timeIntervalSince1970: timestamp)
        }
        if let carPlate: String = "car_plate" <~~ json {
            self.carPlate = carPlate
            CoreController.shared.apiController.searchCar(plate: carPlate)
                .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
                .subscribe { event in
                    switch event {
                    case .next(let response):
                        if response.status == 200, let data = response.dic_data {
                            self.car.value = Car(json: data)
                        }
                    default:
                        break
                    }
                }.addDisposableTo(CoreController.shared.disposeBag)
        }
    }
}
