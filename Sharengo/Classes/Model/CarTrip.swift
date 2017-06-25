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
    
    var car: Variable<Car?> = Variable(nil)
  
    var timer: String? {
        get {
            if let timeStart = self.timeStart {
                let start = timeStart
                let enddt = Date()
                let calendar = Calendar.current
                let datecomponenets = calendar.dateComponents([Calendar.Component.second], from: start, to: enddt)
                if let seconds = datecomponenets.second {
                    let hours = (Float(seconds) / 60 / 60).rounded(.towardZero)
                    let min = (Float(seconds - Int(60*hours)) / 60).rounded(.towardZero)
                    let sec = (Float(seconds - Int(60*min))).rounded(.towardZero)
                    let h = (hours < 10) ? "0\(Int(hours))" : "\(Int(hours))"
                    let m = (min < 10) ? "0\(Int(min))" : "\(Int(min))"
                    let s = (sec < 10) ? "0\(Int(sec))" : "\(Int(sec))"
                    return "<bold>\(h):\(m):\(s)</bold>"
                }
            }
            return nil
        }
    }
    var time: String {
        get {
            if let timeStart = self.timeStart {
                let start = timeStart
                let enddt = Date()
                let calendar = Calendar.current
                let datecomponenets = calendar.dateComponents([Calendar.Component.second], from: start, to: enddt)
                if let seconds = datecomponenets.second {
                    let min = (Float(seconds) / 60).rounded(.towardZero)
                    if min <= 0 {
                        return "0 \("lbl_carBookingPopupTimeMinutes".localized())"
                    } else if min == 1 {
                        return "1 \("lbl_carBookingPopupTimeMinute".localized())"
                    }
                    let m = Int(min)
                    return "\(m) \("lbl_carBookingPopupTimeMinutes".localized())"
                }
            }
            return "0 \("lbl_carBookingPopupTimeMinutes".localized())"
        }
    }
    var minutes: Int {
        get {
            if let timeStart = self.timeStart {
                let start = timeStart
                let enddt = Date()
                let calendar = Calendar.current
                let datecomponenets = calendar.dateComponents([Calendar.Component.second], from: start, to: enddt)
                if let seconds = datecomponenets.second {
                    let min = (Float(seconds) / 60).rounded(.towardZero)
                    return Int(min)
                }
            }
            return 0
        }
    }
    
    init(car: Car) {
        self.car.value = car
    }
    
    required public init?(json: JSON) {
        self.id = "id" <~~ json
        if let timestampStart: Double = "timestamp_start" <~~ json {
            self.timeStart = Date(timeIntervalSince1970: timestampStart)
        }
        if let timestampEnd: Double = "timestamp_end" <~~ json {
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
                            self.car.value = Car(json: data)
                        }
                    default:
                        break
                    }
                }.addDisposableTo(CoreController.shared.disposeBag)
        }
    }
}
