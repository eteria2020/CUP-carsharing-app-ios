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
}
enum SettingSelectionOutput : SelectionOutput {
    case viewModel(ViewModelType)
    case empty
}

final class SettingsViewModel : ListViewModelType, ViewModelTypeSelectable {
    var dataHolder: ListDataHolderType = ListDataHolder.empty
    var settings = [Setting]()
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
        self.title = "lbl_settingsHeaderTitle".localized()

         let settingItem1 = Setting(title: "lbl_settingsCities", icon: "ic_login", viewModel: ViewModelFactory.settingsCities())
         let settingItem2 = Setting(title: "lbl_settingsFavourites", icon: "ic_iscrizione", viewModel: nil)
         let settingItem3 = Setting(title: "lbl_settingsLanguages", icon: "ic_faq_nero", viewModel: ViewModelFactory.settingsLanguages())
         settings.append(settingItem1)
         settings.append(settingItem2)
         settings.append(settingItem3)
     
        self.dataHolder = ListDataHolder(data:Observable.just(settings).structured())
        
        self.selection = Action { input in
            switch input {
            case .item(let indexPath):
                guard let model = self.model(atIndex: indexPath) as?  Setting else { return .empty() }
                if let viewModel = model.viewModel  {
                    return .just(.viewModel(viewModel))
                }
            return .just(.empty)
        }
        }
    }
}
