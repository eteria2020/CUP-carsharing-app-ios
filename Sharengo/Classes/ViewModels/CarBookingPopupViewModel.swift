//
//  CarBookingPopupViewModel.swift
//  Sharengo
//
//  Created by Dedecube on 06/06/17.
//  Copyright © 2017 Dedecube. All rights reserved.
//

import Foundation
import RxSwift
import Boomerang
import Action
import KeychainSwift

/**
 Enum that specifies selection input
 */
public enum CarBookingPopupInput: SelectionInput {
    case open
    case delete
}

/**
 Enum that specifies selection output
 */
public enum CarBookingPopupOutput: SelectionInput {
    case empty
    case open(Car)
    case delete
}

/**
 The CarBookingPopup viewmodel provides data related to display car booking data in CarBookingPopupView
 */
public class CarBookingPopupViewModel: ViewModelTypeSelectable {
    var carBooking: CarBooking?
    var carTrip: CarTrip?
    var pin: String = ""
    var time: Variable<String> = Variable("")
    var hideButtons: Bool = false
    var info: Variable<String?> = Variable(nil)
    var timeTimer: Timer?
    var carBookingPopupView: CarBookingPopupView?
    /// Selection variable
    public var selection: Action<CarBookingPopupInput, CarBookingPopupOutput> = Action { _ in
        return .just(.empty)
    }
    
    // MARK: - Init methods
    
    public required init() {
        self.selection = Action { input in
            switch input {
            case .open:
                if let car = self.carBooking?.car.value {
                    return .just(.open(car))
                } else if let car = self.carTrip?.car.value {
                    return .just(.open(car))
                }
            case .delete:
                return .just(.delete)
            }
            return .just(.empty)
        }
        self.timeTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.updateTime), userInfo: nil, repeats: true)
    }
    
    /**
     This method update ui with Car Booking
     - Parameter carBooking: car booking object
     */
    public func updateWithCarBooking(carBooking: CarBooking) {
        self.carBooking = carBooking
        self.updateData()
        if let car = self.carBooking?.car.value {
            if let location = car.location {
                let key = "address-\(location.coordinate.latitude)-\(location.coordinate.longitude)"
                if let address = UserDefaults.standard.object(forKey: key) as? String {
                    self.info.value = String(format: "lbl_carBookingPopupInfo".localized(), car.plate ?? "", address)
                } else {
                    self.info.value = String(format: "lbl_carBookingPopupInfoPlaceholder".localized(), car.plate ?? "")
                    car.getAddress()
                    car.address.asObservable()
                        .subscribe(onNext: {[weak self] (address) in
                            DispatchQueue.main.async {[weak self]  in
                                if address != nil {
                                    self?.info.value = String(format: "lbl_carBookingPopupInfo".localized(), car.plate ?? "", address!)
                                    UserDefaults.standard.set(address!, forKey: key)
                                }
                            }
                        }).addDisposableTo(disposeBag)
                }
            }
            if car.opened {
                self.hideButtons = true
            } else {
                self.hideButtons = false
            }
        }
    }
    
    /**
     This method update ui with Car Trip
     - Parameter carTrip: car trip object
     */
    public func updateWithCarTrip(carTrip: CarTrip) {
        self.carTrip = carTrip
        self.updateData()
        if let car = self.carTrip?.car.value {
            self.info.value = String(format: "lbl_carBookingPopupInfoPlaceholder".localized(), car.plate ?? "")
            if self.carTrip != nil {
                if self.carTrip?.car.value?.parking == true {
                    self.info.value = String(format: "lbl_carTripParkingPopupInfo".localized(), car.plate ?? "")
                } else {
                    self.info.value = String(format: "lbl_carTripPopupInfo".localized(), car.plate ?? "")
                }
            } else if let address = car.address.value {
                self.info.value = String(format: "lbl_carBookingPopupInfo".localized(), car.plate ?? "", address)
            } else {
                car.getAddress()
                car.address.asObservable()
                    .subscribe(onNext: {[weak self] (address) in
                        DispatchQueue.main.async {[weak self]  in
                            if address != nil {
                                self?.info.value = String(format: "lbl_carBookingPopupInfo".localized(), car.plate ?? "", address!)
                            }
                        }
                    }).addDisposableTo(disposeBag)
            }
            if car.opened {
                self.hideButtons = true
            }
        }
    }
    
    /**
     This method update data
     */
    public func updateData() {
        if let pin = KeychainSwift().get("UserPin") {
            self.pin = String(format: "lbl_carBookingPopupPin".localized(), pin)
        } else {
            self.pin = ""
        }
        self.info.value = ""
        self.updateTime()
    }
    
    @objc fileprivate func updateTime() {
        self.time.value = ""
        if self.carBooking != nil {
            if self.carBookingPopupView?.alpha ?? 0.0 > 0.0 {
                if let timer = self.carBooking?.timer {
                    self.time.value = String(format: "lbl_carBookingPopupTime".localized(), timer)
                }
            }
        } else if self.carTrip != nil {
            if self.carBookingPopupView?.alpha ?? 0.0 > 0.0 {
                if let timer = self.carTrip?.timer {
                    self.time.value = String(format: "lbl_carTripPopupTime".localized(), timer)
                }
            }
        }
    }
}
