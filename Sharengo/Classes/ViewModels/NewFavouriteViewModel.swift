//
//  NewFavouriteViewModel.swift
//  Sharengo
//
//  Created by Dedecube on 28/06/17.
//  Copyright © 2017 Dedecube. All rights reserved.
//

import Foundation
import RxSwift

import Action

/**
 Enum that specifies selection input
 */
public enum NewFavouriteSelectionInput: SelectionInput {
    case empty
}

/**
 Enum that specifies selection output
 */
public enum NewFavouriteSelectionOutput: SelectionOutput {
    case empty
}

/**
 The New favourite model provides data related to display content on new favourite in settings
 */
public final class NewFavouriteViewModel: ViewModelType {
    /// Selection variable
    public lazy var selection:Action<NewFavouriteSelectionInput,NewFavouriteSelectionOutput> = Action { input in
        return .just(.empty)
    }
    
    // MARK: - Init methods
    
    public required init()
    { }
}
