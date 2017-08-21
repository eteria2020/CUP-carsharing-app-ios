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

/**
 Enum that specifies selection input
 */
public enum CarBookingCompletedInput: SelectionInput {
    case openCarRides
}

/**
 Enum that specifies selection output
 */
public enum CarBookingCompletedOutput: SelectionInput {
    case empty
    case openCarRides
}

/**
 The CarBookingCompleted model provides data related to display content on the car booking completed screen
 */
public final class CarBookingCompletedViewModel: ViewModelTypeSelectable {
    /// Variable used to save car trip
    var carTrip: CarTrip
    /// Variable used to save co2 calculation
    var co2: Float
    /// Selection variable
    public var selection: Action<CarBookingCompletedInput, CarBookingCompletedOutput> = Action { _ in
        return .just(.empty)
    }
    
    // MARK: - Init methods
    
    public init(carTrip: CarTrip) {
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
