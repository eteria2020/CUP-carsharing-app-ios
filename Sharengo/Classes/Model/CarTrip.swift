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
 The CarTrip model is used to represent a Car Trip.
 */
public class CarTrip: ModelType, Gloss.Decodable {
    /// Unique identifier
    public var id: Int?
    /// Car Plate
    public var carPlate: String?
    /// Start time of Car Trip
    public var timeStart: Date?
    /// End time of Car Trip
    public var timeEnd: Date?
    /// Boolean used in car trips list
    public var selected = false
    /// Start Location of Car Trip
    public var locationStart: CLLocation?
    /// End Location of Car Trip
    public var locationEnd: CLLocation?
    /// Price of Car Trip
    public var totalCost: Int?
    /// Boolean that determine if price is calculated or not
    public var costComputed: Bool?
    /// Car Object Model used as Car Trip
    public var car: Variable<Car?> = Variable(nil)
    //payable trip
    public var payable: Bool?
    /////popup fake opened
    public var fake: Bool
    /// Timer of carTrip in action used in views
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
    /// Time of carTrip in action used in views
    public var time: String {
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
    /// End time of carTrip in action used in views
    public var endTime: String {
        get {
            if let timeStart = self.timeStart,
                let timeEnd = self.timeEnd {
                let start = timeStart
                let enddt = timeEnd
                let calendar = Calendar.current
                let datecomponents = calendar.dateComponents([Calendar.Component.second], from: start, to: enddt)
                if let second = datecomponents.second {
                    //prendo i secondi li trasformo in minuti e ci aggiungo un minuto se il resto in secondi è >= di 30 
                    let min = (second/60) + ((second % 60) >= 30 ? 1:0)
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
    /// Time of carTrip in action used in views
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
    //modifica ivan
    public var seconds: Int {
        get {
            if let timeStart = self.timeStart {
                let start = timeStart
                let enddt = Date()
                let calendar = Calendar.current
                let datecomponents = calendar.dateComponents([Calendar.Component.second], from: start, to: enddt)
                if let sec = datecomponents.second {
                    return Int(sec)
                }
            }
            return 0
        }
    }

    // MARK: - Init methods
    
    public init(car: Car) {
        self.car.value = car
        self.fake = false
    }
    
    public required init?(json: JSON) {
        self.id = "id" <~~ json
        self.fake = false
        self.totalCost = "total_cost" <~~ json
        self.costComputed = "cost_computed" <~~ json
        self.payable = "payable" <~~ json
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
        if let timestampStart: String = "timestamp_start" <~~ json {
            if let timestampStart = Double(timestampStart){
            self.timeStart = Date(timeIntervalSince1970: timestampStart)
            }
        }
        if let timestampEnd: String = "timestamp_end" <~~ json {
            if let timestampEnd = Double(timestampEnd){
                 self.timeEnd = Date(timeIntervalSince1970: timestampEnd)
            }
        
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

    // MARK - Update methods
    
    /**
     This method is used to update car connected to Car Trip
     */
    public func updateCar(completionClosure: @escaping () ->())
    {
        if let carPlate = self.carPlate
        {
            CoreController.shared.apiController.searchCar(plate: carPlate)
                .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
                .subscribe { event in
                    DispatchQueue.main.async {
                        switch event
                        {
                        case .next(let response):
                            if response.status == 200, let data = response.dic_data {
                                self.car.value = Car(json: data)
                                completionClosure()
                            }
                        default:
                            break
                        }
                    }
                }.addDisposableTo(CoreController.shared.disposeBag)
        }
    }
    
    public func setFake(fake: Bool){
        self.fake = fake
    }
    
}
