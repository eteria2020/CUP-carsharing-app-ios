//
//  FavouritesViewModel.swift
//  Sharengo
//
//  Created by Dedecube on 28/06/17.
//  Copyright © 2017 Dedecube. All rights reserved.
//

import Foundation
import RxSwift
import Boomerang
import Action

enum FavouritesSelectionInput: SelectionInput {
    case empty
}

enum FavouritesSelectionOutput: SelectionOutput {
    case empty
}

final class FavouritesViewModel: ViewModelType {
    lazy var selection:Action<FavouritesSelectionInput,FavouritesSelectionOutput> = Action { input in
        switch input {
        default:
            return .just(.empty)
        }
    }

    init() {

    }
}
