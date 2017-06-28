//
//  NoFavouritesViewModel.swift
//  Sharengo
//
//  Created by Dedecube on 28/06/17.
//  Copyright © 2017 Dedecube. All rights reserved.
//

import Foundation
import RxSwift
import Boomerang
import Action

enum NoFavouritesSelectionInput: SelectionInput {
    case newFavourite
    case empty
}

enum NoFavouritesSelectionOutput: SelectionOutput {
    case newFavourite
    case empty
}

final class NoFavouritesViewModel: ViewModelType {
    lazy var selection:Action<NoFavouritesSelectionInput,NoFavouritesSelectionOutput> = Action { input in
        switch input {
        case .newFavourite:
            return .just(.newFavourite)
        }
        return .just(.empty)
    }

    init() {

    }
}
