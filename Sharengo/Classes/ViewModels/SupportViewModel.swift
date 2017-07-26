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

public enum SupportInput: SelectionInput {
    case empty
}

public enum SupportOutput: SelectionInput {
    case empty
}

final class SupportViewModel: ViewModelTypeSelectable {
    public var selection: Action<SupportInput, SupportOutput> = Action { _ in
        return .just(.empty)
    }
    
    init()
    { }
}
