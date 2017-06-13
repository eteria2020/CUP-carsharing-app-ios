//
//  ProfileViewModel.swift
//  Sharengo
//
//  Created by Dedecube on 13/06/17.
//  Copyright © 2017 Dedecube. All rights reserved.
//

import Foundation
import RxSwift
import Boomerang
import Action

enum ProfileSelectionInput: SelectionInput {
}

enum ProfileSelectionOutput: SelectionOutput {
    case viewModel(ViewModelType)
    case empty
}

final class ProfileViewModel: ViewModelType {
    init() {
    }
}
