//
//  InviteFriendViewModel.swift
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
public enum InviteFriendInput: SelectionInput {
    case empty
}

/**
 Enum that specifies selection output
 */
public enum InviteFriendOutput: SelectionInput {
    case empty
}

/**
 The InviteFriendViewModel provides data related to display content on invite friend
 */
public final class InviteFriendViewModel: ViewModelTypeSelectable {
    /// Selection variable
    public var selection: Action<InviteFriendInput, InviteFriendOutput> = Action { _ in
        return .just(.empty)
    }
    
    // MARK: - Init methods
    
    public required init()
    { }
}
