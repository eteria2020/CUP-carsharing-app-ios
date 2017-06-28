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
    case empty
}

enum NoFavouritesSelectionOutput: SelectionOutput {
    case empty
}

final class NoFavouritesViewModel: ViewModelType {
    lazy var selection:Action<NoFavouritesSelectionInput,NoFavouritesSelectionOutput> = Action { input in
        return .just(.empty)
    }

    init() {

    }
}
