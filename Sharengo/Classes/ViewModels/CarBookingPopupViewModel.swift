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
    case delete(Car)
}

final class CarBookingPopupViewModel: ViewModelTypeSelectable {
    fileprivate var carBooking: CarBooking?
    var pin: String = ""
    var info: String = ""
    var time: String = ""
    var hideButtons: Bool = false
    
    public var selection: Action<CarBookingPopupInput, CarBookingPopupOutput> = Action { _ in
        return .just(.empty)
    }
    
    init() {
        self.selection = Action { input in
            switch input {
            case .open:
                if let car = self.carBooking?.car {
                    return .just(.open(car))
                }
            case .delete:
                if let car = self.carBooking?.car {
                    return .just(.delete(car))
                }
            }

            return .just(.empty)
        }
    }
    
    
    func updateWithCarBooking(carBooking: CarBooking) {
        self.carBooking = carBooking
        self.pin = String(format: "lbl_carBookingPopupPin".localized(), carBooking.pin ?? "")
        self.info = ""
        self.hideButtons = false
        if let car = self.carBooking?.car {
            self.info = String(format: "lbl_carBookingPopupInfo".localized(), car.plate ?? "", car.address.value ?? "")
            if car.opened {
                self.hideButtons = true
            }
        }
        self.time = String(format: "lbl_carBookingPopupTime".localized(), carBooking.time ?? "")
        // TODO: può succedere che l'indirizzo non sia ancora stato calcolato?
    }
}
