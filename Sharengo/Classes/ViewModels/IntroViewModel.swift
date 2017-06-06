//
//  IntroViewModel.swift
//  Sharengo
//
//  Created by Dedecube on 06/06/17.
//  Copyright © 2017 Dedecube. All rights reserved.
//

import Foundation
import RxSwift
import Boomerang
import Action

enum IntroSelectionInput: SelectionInput {
    case item(IndexPath)
}

enum IntroSelectionOutput: SelectionOutput {
    case viewModel(ViewModelType)
}

final class IntroViewModel: ViewModelType { // ViewModelTypeSelectable {
    /*
    lazy var selection:Action<HomeSelectionInput,HomeSelectionOutput> = Action { input in
    }
    */
    
    init() {
    }
}
