//
//  UserAreaViewModel.swift
//  Sharengo
//
//  Created by Dedecube on 26/07/17.
//  Copyright © 2017 Dedecube. All rights reserved.
//

import Foundation
import RxSwift
import Action
import Boomerang

/**
 Enum that specifies selection input
 */
public enum UserAreaInput: SelectionInput {
}

/**
 Enum that specifies selection output
 */
public enum UserAreaOutput: SelectionInput {
    case empty
}

/**
 The User Area viewmodel provides data related to display content on User Area VC
 */
public class UserAreaViewModel: ViewModelTypeSelectable {
    /// Selection variable
    public var selection: Action<UserAreaInput, UserAreaOutput> = Action { input in
        return .just(.empty)
    }
    
    public required init()
    {
    }
}
