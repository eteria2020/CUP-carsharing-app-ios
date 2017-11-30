//
//  NoCarTripsViewModel.swift
//  Sharengo
//
//  Created by Dedecube on 28/06/17.
//  Copyright © 2017 Dedecube. All rights reserved.
//

import Foundation
import RxSwift
import Boomerang
import Action

/**
 Enum that specifies selection input
 */
public enum NoCarTripsSelectionInput: SelectionInput {
    case empty
}

/**
 Enum that specifies selection output
 */
public enum NoCarTripsSelectionOutput: SelectionOutput {
    case empty
}

/**
 The NoCarTripsViewModel provides data related to display content on no car trips screen
 */
public class NoCarTripsViewModel: ViewModelType {
    /// Selection variable
    public lazy var selection:Action<NoFavouritesSelectionInput,NoFavouritesSelectionOutput> = Action { input in
        switch input {
        default:
            return .just(.empty)
        }
    }

    // MARK: Init methods
    
    public required init()
    { }
}
