//
//  SettingsLanguagesViewModel.swift
//  Sharengo
//
//  Created by Fabrizio Infante on 27/06/17.
//  Copyright © 2017 Dedecube. All rights reserved.
//

import Foundation
import RxSwift
import Boomerang
import Action

enum SettingsLanguageSelectionInput : SelectionInput {
    case item(IndexPath)
}
enum SettingsLanguageSelectionOutput : SelectionOutput {
    case viewModel(ViewModelType)
}

final class SettingsLanguagesViewModel : ListViewModelType, ViewModelTypeSelectable {
    var dataHolder: ListDataHolderType = ListDataHolder()
    
    func itemViewModel(fromModel model: ModelType) -> ItemViewModelType? {
        guard let item = model as? SettingsLanguage else {
            return nil
        }
        return ViewModelFactory.__proper_factory_method_here()
    }
    
    lazy var selection:Action<SettingsLanguageSelectionInput,SettingsLanguageSelectionOutput> = Action { input in
        switch input {
        case .item(let indexPath):
            guard let model = (self.model(atIndex:indexPath) as? SettingsLanguage) else {
                return .empty()
            }
            let destinationViewModel = __proper_factory_method_here__
            return .just(.viewModel(destinationViewModel))
        }
    }
    
    
    init() {
        
    }
}
