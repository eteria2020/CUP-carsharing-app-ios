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
}

final class CarPopupViewModel: ViewModelTypeSelectable {
    var showType: Variable<Bool> = Variable(false)
    
    public var selection: Action<CarPopupInput, CarPopupOutput> = Action { _ in
        return .just(.empty)
    }
    
    init() {
        self.selection = Action { input in
            switch input {
            case .open:
                print("Open doors")
                break
            case .book:
                print("Book car")
                break
            }
            return .just(.empty)
        }
    }
    
    func updateWithCar(car: Car) {
        showType.value = false
        if car.nearest {
            showType.value = true
        }
    }
}
