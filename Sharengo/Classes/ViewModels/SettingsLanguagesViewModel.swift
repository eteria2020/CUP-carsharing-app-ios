//
//  SettingsLanguagesViewModel.swift
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

enum SettingsLanguageSelectionInput : SelectionInput {
    case item(IndexPath)
}
enum SettingsLanguageSelectionOutput : SelectionOutput {
    case viewModel(ViewModelType)
    case empty
}

final class SettingsViewModel : ListViewModelType, ViewModelTypeSelectable {
    var dataHolder: ListDataHolderType = ListDataHolder.empty
    var languages = [Language]()
    var title = ""
    fileprivate var resultsDispose: DisposeBag?
    
    lazy var selection:Action<SettingSelectionInput,SettingSelectionOutput> = Action { input in
        return .empty()
    }
    
    func itemViewModel(fromModel model: ModelType) -> ItemViewModelType? {
        if let item = model as? Setting {
            return ViewModelFactory.settingItem(fromModel: item)
        }
        return nil
    }
    
    init() {
        self.title = "lbl_settingsLanguagesHeaderTitle".localized()
        
        let settingItem1 = Setting(title: "language_italian", icon: "ic_login", viewModel: ViewModelFactory.login())
        let settingItem2 = Setting(title: "language_english", icon: "ic_iscrizione", viewModel: ViewModelFactory.signup())
        settings.append(settingItem1)
        settings.append(settingItem2)
        settings.append(settingItem3)
        
        self.dataHolder = ListDataHolder(data:Observable.just(settings).structured())
        
        self.selection = Action { input in
            switch input {
            case .item(let indexPath):
                guard let model = self.model(atIndex: indexPath) as?  Setting else { return .empty() }
                if let viewModel = model.viewModel  {
                    switch viewModel {
                    case is HomeViewModel:
                        return .just(.viewModel(viewModel))
                    default:
                        return .just(.viewModel(viewModel))
                    }
                }
                return .just(.empty)
            }
        }
    }
}
