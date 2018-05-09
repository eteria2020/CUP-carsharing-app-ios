//
//  LegalNoteModel.swift
//  Sharengo
//
//  Created by sharengo on 09/05/18.
//  Copyright © 2018 CSGroup. All rights reserved.
//

import Foundation
import RxSwift
import Action
import Boomerang

public enum LegalNoteInput: SelectionInput {
}

public enum LegalNoteOutput: SelectionInput {
    case empty
}

final class  LegalNoteViewModel: ViewModelTypeSelectable {
    public var selection: Action<LegalNoteInput, LegalNoteOutput> = Action { input in
        return .just(.empty)
    }
}
