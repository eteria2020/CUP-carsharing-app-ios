//
//  CarPopupViewModel.swift
//  Sharengo
//
//  Created by Dedecube on 19/05/17.
//  Copyright © 2017 Dedecube. All rights reserved.
//

import Foundation
import RxSwift
import Boomerang
import Action

public enum CarPopupInput: SelectionInput {
    case open
    case book
}

public enum CarPopupOutput: SelectionInput {
    case empty
    case open(Car)
    case book(Car)
}

final class CarPopupViewModel: ViewModelTypeSelectable {
    fileprivate var car: Car?
    var type: Variable<String> = Variable("")
    
    public var selection: Action<CarPopupInput, CarPopupOutput> = Action { _ in
        return .just(.empty)
    }
    
    init() {
        self.selection = Action { input in
            switch input {
            case .open:
                if let car = self.car {
                    return .just(.open(car))
                }
            case .book:
                if let car = self.car {
                    return .just(.book(car))
                }
            }
            return .just(.empty)
        }
    }
    
    func updateWithCar(car: Car) {
        self.car = car
        self.type.value = car.type
    }
}
