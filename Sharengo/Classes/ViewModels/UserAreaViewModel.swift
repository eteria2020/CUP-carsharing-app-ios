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

public enum UserAreaInput: SelectionInput {
}

public enum UserAreaOutput: SelectionInput {
    case empty
}

final class UserAreaViewModel: ViewModelTypeSelectable {
    public var selection: Action<UserAreaInput, UserAreaOutput> = Action { input in
        return .just(.empty)
    }
}
