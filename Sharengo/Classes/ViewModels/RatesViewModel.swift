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
import KeychainSwift

/**
 Enum that specifies selection input
 */
public enum RatesInput: SelectionInput {
    case empty
}

/**
 Enum that specifies selection output
 */
public enum RatesOutput: SelectionInput {
    case empty
}

/**
 The RatesViewModel provides data related to display Share'ngo rates
 */
public class RatesViewModel: ViewModelTypeSelectable {
    /// Selection variable
    public var selection: Action<RatesInput, RatesOutput> = Action { input in
        switch input {
        case .empty:
            return .just(.empty)
        }
    }
    /// Variable used to save rates description
    public var ratesDescription: Variable<String> = Variable("")
    /// Variable used to save bonus description
    public var bonusDescription: Variable<String> = Variable("")
    
    // MARK: - Init methods
    
    public required init()
    {
        self.updateValues()
    }
    
    // MARK: - Update methods
    
    /**
     This method updates Sharen'go rates depending on whetever user is logged or not
     */
    public func updateValues() {
        var basicRate = 0.28
        var oneHourRate = 12.0
        var dayRate = 50.0
        let reservationRate = 0.0
        var bonusMinutes = 0
        
        if KeychainSwift().get("Username") == nil || KeychainSwift().get("Password") == nil {
        } else {
            let discountRate = Int(KeychainSwift().get("UserDiscountRate") ?? "0") ?? 0
            basicRate = 0.28 - (0.28 * Double(discountRate) / 100)
            oneHourRate = 12.00 - (12.00 * Double(discountRate) / 100)
            dayRate = 50.00 - (50.00 * Double(discountRate) / 100)
            bonusMinutes = Int(KeychainSwift().get("UserBonus") ?? "0") ?? 0
        }
        
        self.ratesDescription.value = String(format: "lbl_ratesRatesDescription".localized(), basicRate, oneHourRate, dayRate, reservationRate).replacingOccurrences(of: ".", with: ",").replacingOccurrences(of: ",00", with: "")
        self.bonusDescription.value = String(format: "lbl_ratesBonusDescription".localized(), bonusMinutes).replacingOccurrences(of: ".", with: ",").replacingOccurrences(of: ",00", with: "")
    }
}
