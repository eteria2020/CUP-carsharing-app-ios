//
//  PinViewModel.swift
//  Sharengo
//
//  Created by Dedecube on 29/08/17.
//  Copyright © 2017 Dedecube. All rights reserved.
//

import Foundation
import RxSwift
import Action
import Boomerang
import KeychainSwift

public enum PinInput: SelectionInput {
    case empty
}

public enum PinOutput: SelectionInput {
    case empty
}

final class PinViewModel: ViewModelTypeSelectable {
    public var selection: Action<PinInput, PinOutput> = Action { input in
        switch input {
        case .empty:
            return .just(.empty)
        }
    }
    var PinDescription: Variable<String> = Variable("")
    
    init()
    {
        self.updateValues()
    }
    
    func updateValues() {
        
        if let discountRate = KeychainSwift().get("UserPin"){
            self.PinDescription.value = discountRate
        }
    }
}
