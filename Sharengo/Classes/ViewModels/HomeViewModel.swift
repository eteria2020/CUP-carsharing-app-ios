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
import KeychainSwift

/**
 Enum that specifies home item type
 */
public enum HomeItem {
    case searchCar
    case profile
    case feeds
}

/**
 Enum that specifies selection input
 */
public enum HomeSelectionInput: SelectionInput {
    case searchCars
    case profile
    case feeds
}

/**
 Enum that specifies selection output
 */
public enum HomeSelectionOutput: SelectionOutput {
    case viewModel(ViewModelType)
    case feeds
}

/**
 The Home model provides data related to display content on the
 */
public final class HomeViewModel: ViewModelTypeSelectable {
    /// Selection variable
    public lazy var selection:Action<HomeSelectionInput,HomeSelectionOutput> = Action { input in
        switch input {
        case .searchCars:
            return .just(.viewModel(ViewModelFactory.map(type: .searchCars)))
        case .profile:
            if KeychainSwift().get("Username") == nil || KeychainSwift().get("Password") == nil {
                return .just(.viewModel(ViewModelFactory.login(nextViewModel: ViewModelFactory.profile())))
            } else {
                return .just(.viewModel(ViewModelFactory.profile()))
            }
        case .feeds:
            return .just(.feeds)
        }
    }
    
    // MARK: - Init methods
    
    public init() {
    }
}
