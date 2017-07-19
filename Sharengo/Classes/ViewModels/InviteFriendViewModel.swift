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

public enum InviteFriendInput: SelectionInput {
    case empty
}

public enum InviteFriendOutput: SelectionInput {
    case empty
}

final class InviteFriendViewModel: ViewModelTypeSelectable {
    public var selection: Action<InviteFriendInput, InviteFriendOutput> = Action { _ in
        return .just(.empty)
    }
    
    init()
    { }
}
