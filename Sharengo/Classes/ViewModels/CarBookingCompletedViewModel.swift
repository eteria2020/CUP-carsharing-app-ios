//
//  CarBookingCompletedViewModel.swift
//  Sharengo
//
//  Created by Dedecube on 09/06/17.
//  Copyright © 2017 Dedecube. All rights reserved.
//

import Foundation
import RxSwift
import Action
import Boomerang

public enum CarBookingCompletedInput: SelectionInput {
    case openCarRides
}

public enum CarBookingCompletedOutput: SelectionInput {
    case empty
    case openCarRides
}

final class CarBookingCompletedViewModel: ViewModelTypeSelectable {
    var carTrip: CarTrip
    var co2: Float
    
    public var selection: Action<CarBookingCompletedInput, CarBookingCompletedOutput> = Action { _ in
        return .just(.empty)
    }
    
    init(carTrip: CarTrip) {
        self.carTrip = carTrip
        self.co2 = Float(((Float(carTrip.minutes) / 60) * 17) * 106)
        self.selection = Action { input in
            switch input {
            case .openCarRides:
                return .just(.openCarRides)
            }
        }
    }
}
