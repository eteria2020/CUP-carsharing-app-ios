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
 The CarBooking model is used to represent a car booking action.
 */
public class CarBooking: ModelType, Decodable {
    /// Unique identifier of car booking
    public var id: Int?
    /// Boolean that shows if car booking is active or not
    public var isActive: Bool = false
    /// Plate of booked car
    public var carPlate: String?
    /// Start time of car booking
    public var timeStart: Date?
    /// Max duration time of car booking
    public var timeLength: Int = 1200
    /// Car object used to read info about car (address, for example)
    public var car: Variable<Car?> = Variable(nil)
    /// Timer of current car booked used in car booking popup (11:11 minutes, for example)
    public var timer: String? {
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
                        if CoreController.shared.currentCarBooking != nil {
                            if CoreController.shared.currentCarTrip == nil {
                                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "closeCarBookingPopupView"), object: nil)
                                CoreController.shared.notificationIsShowed = true
                                NotificationsController.showNotification(title: "banner_carBookingDeletedTitle".localized(), description: "banner_carBookingDeletedDescription".localized(), carTrip: nil, source: CoreController.shared.currentViewController ?? UIViewController())
                                CoreController.shared.currentCarBooking = nil
                                CoreController.shared.allCarBookings = []
                            }
                        }
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
    /// Minutes of current car booked used in update data
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

    // MARK: - Init methods
    
    public init(car: Car) {
        self.car.value = car
    }
    
    public required init?(json: JSON) {
        self.id = "id" <~~ json
        self.isActive = "is_active" <~~ json ?? false
        self.timeLength = "length" <~~ json ?? 1200
        if let timestamp: Double = "reservation_timestamp" <~~ json {
            self.timeStart = Date(timeIntervalSince1970: timestamp)
        }
        if let carPlate: String = "car_plate" <~~ json {
            self.carPlate = carPlate
            /*
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
            */
        }
    }
    
    public func updateCar(completionClosure: @escaping () ->()) {
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
