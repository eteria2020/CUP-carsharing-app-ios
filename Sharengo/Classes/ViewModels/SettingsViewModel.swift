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
        self.updateData()
        self.selection = Action { input in
            switch input {
            case .item(let indexPath):
                guard let model = self.model(atIndex: indexPath) as?  Setting else { return .empty() }
                if let viewModel = model.viewModel  {
                    if viewModel is NoFavouritesViewModel {
                        var favourites: Bool = false
                        if let array = UserDefaults.standard.object(forKey: "favouritesArray") as? Data {
                            if let unarchivedArray = NSKeyedUnarchiver.unarchiveObject(with: array) as? [FavouriteAddress] {
                                if unarchivedArray.count > 0 {
                                    favourites = true
                                }
                            }
                        }
                        
                        if favourites {
                            return .just(.viewModel(ViewModelFactory.favourites()))
                        }
                    }
                    return .just(.viewModel(viewModel))
                }
            return .just(.empty)
        }
        }
    }
    
    func updateData() {
        let settingItem1 = Setting(title: "lbl_settingsCities", icon: "ic_imposta_citta", viewModel: ViewModelFactory.settingsCities())
        settings.append(settingItem1)
        
        let settingItem2 = Setting(title: "lbl_settingsFavourites", icon: "ic_imposta_indirizzi", viewModel: ViewModelFactory.noFavourites())
        settings.append(settingItem2)
        
        let settingItem3 = Setting(title: "lbl_settingsLanguages", icon: "ic_imposta_lingua", viewModel: ViewModelFactory.settingsLanguages())
        settings.append(settingItem3)
        
        self.dataHolder = ListDataHolder(data:Observable.just(settings).structured())
    }
}
