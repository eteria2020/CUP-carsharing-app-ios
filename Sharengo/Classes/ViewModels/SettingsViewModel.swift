//
//  SettingsViewModel.swift
//  Sharengo
//
//  Created by Dedecube on 27/06/17.
//  Copyright © 2017 Dedecube. All rights reserved.
//

import Foundation
import RxSwift
import Boomerang
import Action
import KeychainSwift

enum SettingSelectionInput : SelectionInput {
    case item(IndexPath)
    case profileEco
}
enum SettingSelectionOutput : SelectionOutput {
    case viewModel(ViewModelType)
    case logout
    case empty
}

final class SettingsViewModel : ListViewModelType, ViewModelTypeSelectable {
    var dataHolder: ListDataHolderType = ListDataHolder()
    
    func itemViewModel(fromModel model: ModelType) -> ItemViewModelType? {
        guard let item = model as? Setting else {
            return nil
        }
        return ViewModelFactory.__proper_factory_method_here()
    }
    
    lazy var selection:Action<SettingSelectionInput,SettingSelectionOutput> = Action { input in
        switch input {
        case .item(let indexPath):
            guard let model = (self.model(atIndex:indexPath) as? Setting) else {
                return .empty()
            }
            let destinationViewModel = __proper_factory_method_here__
            return .just(.viewModel(destinationViewModel))
        }
    }
    
    
    init() {
        
    }
}
