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

public enum CarBookingPopupInput: SelectionInput {
    case open
    case delete
}

public enum CarBookingPopupOutput: SelectionInput {
    case empty
    case open(Car)
    case delete()
}

final class CarBookingPopupViewModel: ViewModelTypeSelectable {
    var carBooking: CarBooking?
    var carTrip: CarTrip?
    var pin: String = ""
    var time: Variable<String> = Variable("")
    var hideButtons: Bool = false
    var info: Variable<String?> = Variable(nil)
    var timeTimer: Timer?
    
    public var selection: Action<CarBookingPopupInput, CarBookingPopupOutput> = Action { _ in
        return .just(.empty)
    }
    
    init() {
        self.selection = Action { input in
            switch input {
            case .open:
                if let car = self.carBooking?.car.value {
                    return .just(.open(car))
                }
            case .delete:
                return .just(.delete())
            }

            return .just(.empty)
        }
        self.timeTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.updateTime), userInfo: nil, repeats: true)
    }
    
    func updateWithCarBooking(carBooking: CarBooking) {
        self.carBooking = carBooking
        self.updateData()
        if let car = self.carBooking?.car.value {
            self.info.value = String(format: "lbl_carBookingPopupInfoPlaceholder".localized(), car.plate ?? "")
            if let address = car.address.value {
                self.info.value = String(format: "lbl_carBookingPopupInfo".localized(), car.plate ?? "", address)
            } else {
                car.getAddress()
                car.address.asObservable()
                    .subscribe(onNext: {[weak self] (address) in
                        DispatchQueue.main.async {
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
    
    func updateWithCarTrip(carTrip: CarTrip) {
        self.carTrip = carTrip
        self.updateData()
        if let car = self.carTrip?.car.value {
            self.info.value = String(format: "lbl_carBookingPopupInfoPlaceholder".localized(), car.plate ?? "")
            if let address = car.address.value {
                self.info.value = String(format: "lbl_carBookingPopupInfo".localized(), car.plate ?? "", address)
            } else {
                car.getAddress()
                car.address.asObservable()
                    .subscribe(onNext: {[weak self] (address) in
                        DispatchQueue.main.async {
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
    
    func updateData() {
        if let pin = UserDefaults.standard.object(forKey: "UserPin") as? Int {
            self.pin = String(format: "lbl_carBookingPopupPin".localized(), pin)
        } else {
            self.pin = ""
        }
        self.info.value = ""
        self.hideButtons = false
        self.updateTime()
    }
    
    @objc fileprivate func updateTime() {
        self.time.value = ""
        if self.carBooking?.car.value?.opened == false {
            if let time = self.carBooking?.time {
                self.time.value = String(format: "lbl_carBookingPopupTime".localized(), time)
            }
        }
    }
}
