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

/**
 The CarTrip model is used to represent a car trip (current or archived).
 */
public class CarTrip: ModelType, Decodable {
    /// Unique identifier of car trip
    public var id: Int?
    /// Plate of booked car
    public var carPlate: String?
    /// Start time of car trip
    public var timeStart: Date?
    /// End time of car trip
    public var timeEnd: Date?
    /// Start location of car trip
    public var locationStart: CLLocation?
    /// End location of car trip
    public var locationEnd: CLLocation?
    /// Price of car trip
    public var totalCost: Int?
    /// Boolean that determine if price is calculated or not
    public var costComputed: Bool?
    /// Car object used to read info about car (address, for example)
    public var car: Variable<Car?> = Variable(nil)
    /// Timer of current car trip used in car booking popup (11:11:11, for example)
    public var timer: String? {
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
    /// Time of current car trip used in notification (1 minute, for example). If seconds are more than 30 1 minute is added
    public var time: String {
        get {
            if let timeStart = self.timeStart {
                let start = timeStart
                let enddt = Date()
                let calendar = Calendar.current
                let datecomponents = calendar.dateComponents([Calendar.Component.minute, Calendar.Component.second], from: start, to: enddt)
                if var min = datecomponents.minute, let sec = datecomponents.second {
                    if sec > 30 {
                        min += 1
                    }
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
    /// Time of current car trip used in car trips list (1 minute, for example)
    public var endTime: String {
        get {
            if let timeStart = self.timeStart,
                let timeEnd = self.timeEnd {
                let calendar = Calendar.current
                let datecomponents = calendar.dateComponents([Calendar.Component.minute, Calendar.Component.second], from: timeStart, to: timeEnd)
                if var min = datecomponents.minute, let sec = datecomponents.second {
                    if sec > 30 {
                        min += 1
                    }
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
    /// Minutes of current car trip used in update data
    public var minutes: Int {
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
    /// Variable used from update data when car in car trip is parked
    public var changedStatus: Date?
    /// Minutes of car in car trip parked used in update data
    public var changedStatusMinutes: Int {
        get {
            if let timeStart = self.changedStatus {
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

    // MARK: - Init methods
    
    public init(car: Car) {
        self.car.value = car
    }
    
    public required init?(json: JSON) {
        self.id = "id" <~~ json
        self.totalCost = "total_cost" <~~ json
        self.costComputed = "cost_computed" <~~ json
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
                            DispatchQueue.main.async {[weak self]  in
                                self?.car.value = Car(json: data)
                            }
                        }
                    default:
                        break
                    }
                }.addDisposableTo(CoreController.shared.disposeBag)
        }
    }

    // MARK - Update methods
    
    /**
     This method is used to update car connected to car trip
     */
    public func updateCar(completionClosure: @escaping () ->()) {
        if self.minutes < 1 {
            if self.car.value != nil {
                completionClosure()
                return
            }
        } else if self.changedStatus != nil {
            if self.changedStatusMinutes < 1 {
                completionClosure()
                return
            }
        }
        if let carPlate = self.carPlate {
            CoreController.shared.apiController.searchCar(plate: carPlate)
                .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
                .subscribe { event in
                    switch event {
                    case .next(let response):
                        if response.status == 200, let data = response.dic_data {
                            DispatchQueue.main.async {[weak self]  in
                                self?.car.value = Car(json: data)
                            }
                            completionClosure()
                        }
                    default:
                        break
                    }
                }.addDisposableTo(CoreController.shared.disposeBag)
        }
    }
}
