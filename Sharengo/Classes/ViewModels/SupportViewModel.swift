//
//  SupportViewModel.swift
//  Sharengo
//
//  Created by Dedecube on 19/07/17.
//  Copyright © 2017 Dedecube. All rights reserved.
//

import Foundation
import RxSwift
import Action
import Boomerang

/**
 Enum that specifies selection input
 */
public enum SupportInput: SelectionInput {
    case empty
}

/**
 Enum that specifies selection output
 */
public enum SupportOutput: SelectionInput {
    case empty
}

/**
 The SupportViewModel provides data related to display content on support screen
 */
public final class SupportViewModel: ViewModelTypeSelectable {
    /// Selection variable
    public var selection: Action<SupportInput, SupportOutput> = Action { _ in
        return .just(.empty)
    }
    
    // MARK: - Init methods
    
    public required init()
    { }
}
