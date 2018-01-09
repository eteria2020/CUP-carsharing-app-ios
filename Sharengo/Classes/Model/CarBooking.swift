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
 The CarBooking model is used to represent a Car Booking action.
 */
public class CarBooking: ModelType, Gloss.Decodable {
    /// Unique identifier
    var id: Int?
    /// Boolean that show if CarBooking is activated or not
    var isActive: Bool = false
    /// Car Plate of booked car if CarBooking is active
    var carPlate: String?
    /// Start time of Car Booking
    var timeStart: Date?
    /// Duration time of Car Booking
    var timeLength: Int = 1200
    /// Car Object Model used as Car Booked
    var car: Variable<Car?> = Variable(nil)
    /// Timer of carBooking in action used in views
    var timer: String? {
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
