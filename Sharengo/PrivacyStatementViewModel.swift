//
//  PrivacyStatementModel.swift
//  Sharengo
//
//  Created by sharengo on 09/05/18.
//  Copyright © 2018 CSGroup. All rights reserved.
//

import Foundation
import RxSwift
import Action
import Boomerang

public enum PrivacyStatementInput: SelectionInput {
}

public enum PrivacyStatementOutput: SelectionInput {
    case empty
}

final class PrivacyStatementViewModel: ViewModelTypeSelectable {
    public var selection: Action<PrivacyStatementInput, PrivacyStatementOutput> = Action { input in
        return .just(.empty)
    }
}
