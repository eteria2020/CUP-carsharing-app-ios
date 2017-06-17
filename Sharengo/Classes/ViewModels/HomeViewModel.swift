//
//  HomeViewModel.swift
//  Sharengo
//
//  Created by Dedecube on 18/05/17.
//  Copyright © 2017 Dedecube. All rights reserved.
//

import Foundation
import RxSwift
import Boomerang
import Action

enum HomeSelectionInput: SelectionInput {
    case searchCars
    case profile
}

enum HomeSelectionOutput: SelectionOutput {
    case viewModel(ViewModelType)
}

final class HomeViewModel: ViewModelTypeSelectable {
    lazy var selection:Action<HomeSelectionInput,HomeSelectionOutput> = Action { input in
        switch input {
        case .searchCars:
            return .just(.viewModel(ViewModelFactory.searchCars()))
        case .profile:
            if UserDefaults.standard.object(forKey: "UserPin") == nil || UserDefaults.standard.object(forKey: "Username") == nil || UserDefaults.standard.object(forKey: "Password") == nil {
                return .just(.viewModel(ViewModelFactory.login()))
            } else {
                return .just(.viewModel(ViewModelFactory.profile()))
            }
        }
    }
    
    init() {
    }
}
