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
    var selected = false
    var kmStart: Int?
    var kmEnd: Int?
    var locationStart: CLLocation?
    var locationEnd: CLLocation?
    
    var car: Variable<Car?> = Variable(nil)
    
    var timer: String? {
        get {
            if let timeStart = self.timeStart {
                let start = timeStart
                let enddt = Date()
                let calendar = Calendar.current
                let datecomponents = calendar.dateComponents([Calendar.Component.second, Calendar.Component.minute, Calendar.Component.hour], from: start, to: enddt)
                if let s = datecomponents.second, let m = datecomponents.minute, let h = datecomponents.hour
                {
                    var min = "\(m)"
                    if m < 10 {
                        min = "0\(m)"
                    }
                    var sec = "\(s)"
                    if s < 10 {
                        sec = "0\(s)"
                    }
                    var hrs = "\(h)"
                    if h < 10 {
                        hrs = "0\(h)"
                    }
                    return "<bold>\(hrs):\(min):\(sec)</bold>"
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
                let datecomponents = calendar.dateComponents([Calendar.Component.minute], from: start, to: enddt)
                if let min = datecomponents.minute {
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
    var endTime: String {
        get {
            if let timeStart = self.timeStart,
                let timeEnd = self.timeEnd {
                let start = timeStart
                let enddt = timeEnd
                let calendar = Calendar.current
                let datecomponents = calendar.dateComponents([Calendar.Component.minute], from: start, to: enddt)
                if let min = datecomponents.minute {
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
                let datecomponents = calendar.dateComponents([Calendar.Component.minute], from: start, to: enddt)
                if let min = datecomponents.minute {
                    return Int(min)
                }
            }
            return 0
        }
    }
    
    init(car: Car) {
        self.car.value = car
    }
    
    static var empty:CarTrip {
        return CarTrip(car: Car())
    }
    
    func updateCar(completionClosure: @escaping () ->()) {
        if let carPlate = self.carPlate {
            CoreController.shared.apiController.searchCar(plate: carPlate)
                .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
                .subscribe { event in
                    switch event {
                    case .next(let response):
                        if response.status == 200, let data = response.dic_data {
                            self.car.value = Car(json: data)
                            completionClosure()
                        }
                    default:
                        break
                    }
                }.addDisposableTo(CoreController.shared.disposeBag)
        }
    }
    
    required public init?(json: JSON) {
        self.id = "id" <~~ json
        self.kmStart = "km_start" <~~ json
        self.kmEnd = "km_end" <~~ json
        if let latitude: String = "lat_start" <~~ json, let longitude: String = "lon_start" <~~ json {
            if let lat: CLLocationDegrees = Double(latitude), let lon: CLLocationDegrees = Double(longitude) {
                self.locationStart = CLLocation(latitude: lat, longitude: lon)
            }
        }
        if let latitude: String = "lat_end" <~~ json, let longitude: String = "lon_end" <~~ json {
            if let lat: CLLocationDegrees = Double(latitude), let lon: CLLocationDegrees = Double(longitude) {
                self.locationEnd = CLLocation(latitude: lat, longitude: lon)
            }
        }
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
