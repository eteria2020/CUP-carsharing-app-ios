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
    case open
    case book
}

final class CarPopupViewModel: ViewModelTypeSelectable {
    var type: Variable<String> = Variable("")
    
    public var selection: Action<CarPopupInput, CarPopupOutput> = Action { _ in
        return .just(.empty)
    }
    
    init() {
        self.selection = Action { input in
            switch input {
            case .open:
                return .just(.open)
            case .book:
                return .just(.book)
            }
            return .just(.empty)
        }
    }
    
    func updateWithCar(car: Car) {
        if car.nearest {
            self.type.value = "lbl_carPopupType".localized()
        } else {
            self.type.value = ""
        }
    }
}
