//
//  RatesViewModel.swift
//  Sharengo
//
//  Created by Dedecube on 29/08/17.
//  Copyright © 2017 Dedecube. All rights reserved.
//

import Foundation
import RxSwift
import Action
import Boomerang

public enum RatesInput: SelectionInput {
    case empty
}

public enum RatesOutput: SelectionInput {
    case empty
}

final class RatesViewModel: ViewModelTypeSelectable {
    public var selection: Action<RatesInput, RatesOutput> = Action { input in
        switch input {
        case .empty:
            return .just(.empty)
        }
    }
    var ratesDescription: Variable<String> = Variable("")
    var bonusDescription: Variable<String> = Variable("")
    
    init()
    {
        let basicRate = 0.1
        let oneHourRate = 0.2
        let dayRate = 0.3
        let reservationRate = 0.4
        let bonusMinutes: Int? = 0

        
        self.ratesDescription.value = String(format: "lbl_ratesRatesDescription".localized(), "\(basicRate)", "\(oneHourRate)", "\(dayRate)", "\(reservationRate)")

        if bonusMinutes != nil
        {
            self.bonusDescription.value = String(format: "lbl_ratesBonusDescription".localized(), "\(bonusMinutes!)")
        }
        else
        {
            self.bonusDescription.value = ""
        }
    }
}
