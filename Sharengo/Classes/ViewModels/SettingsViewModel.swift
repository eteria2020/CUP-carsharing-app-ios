//
//  SettingsViewModel.swift
//  Sharengo
//
//  Created by Dedecube on 27/06/17.
//  Copyright © 2017 Dedecube. All rights reserved.
//

import Foundation
import RxSwift

import Action
import KeychainSwift

/**
 Enum that specifies selection input
 */
public enum SettingSelectionInput : SelectionInput {
    case item(IndexPath)
}

/**
 Enum that specifies selection output
 */
public enum SettingSelectionOutput : SelectionOutput {
    case viewModel(ViewModelType)
    case empty
}

/**
 The Setting model provides data related to display content on settings
 */
public final class SettingsViewModel : ListViewModelType, ViewModelTypeSelectable {
    fileprivate var resultsDispose: DisposeBag?
    /// ViewModel variable used to save data
    public var dataHolder: ListDataHolderType = ListDataHolder.empty
    /// ViewModel variable used to save data
    public var settings = [Setting]()
    /// Variable used to save title
    var title = ""
    /// Selection variable
    public lazy var selection:Action<SettingSelectionInput,SettingSelectionOutput> = Action { input in
        return .empty()
    }
    
    // MARK: - ViewModel methods
    
    public func itemViewModel(fromModel model: ModelType) -> ItemViewModelType? {
        if let item = model as? Setting {
            return ViewModelFactory.settingItem(fromModel: item)
        }
        return nil
    }
    
    // MARK: - Init methods
    
    public init() {
        self.title = "lbl_settingsHeaderTitle".localized()
        self.updateData()
        self.selection = Action { input in
            switch input {
            case .item(let indexPath):
                guard let model = self.model(atIndex: indexPath) as?  Setting else { return .empty() }
                if let viewModel = model.viewModel  {
                    if viewModel is NoFavouritesViewModel {
                        var favourites: Bool = false
                        if var dictionary = UserDefaults.standard.object(forKey: "favouritesAddressDic") as? [String: Data] {
                            if let username = KeychainSwift().get("Username") {
                                if let array = dictionary[username] {
                                    if let unarchivedArray = NSKeyedUnarchiver.unarchiveObject(with: array) as? [FavouriteAddress] {
                                        if unarchivedArray.count > 0 {
                                            favourites = true
                                        }
                                    }
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
    
    /**
     This method updates settings options
     */
    public func updateData() {
        settings.removeAll()
        
        //  Only if pushes are refused, show an option to advise user to go in settings and activate it
        if PushNotificationController.pushNotificationIsRefused && PushNotificationController.pushNotificationHasPrompted
        {
            let item = Setting(title: "lbl_settingsNotifications", icon: "icon_alert_white", viewModel: ViewModelFactory.settingsNotifications())
            settings.append(item)
        }
        
        //if(Config().language == "it"){
            //let settingItem1 = Setting(title: "lbl_settingsCities", icon: "ic_imposta_citta", viewModel: ViewModelFactory.settingsCities())
            //settings.append(settingItem1)
            //let settingItem2 = Setting(title: "lbl_settingsFavourites", icon: "ic_imposta_indirizzi", viewModel: ViewModelFactory.noFavourites())
            //settings.append(settingItem2)
        //}
        
        let settingItem3 = Setting(title: "lbl_settingsLanguages", icon: "ic_imposta_lingua", viewModel: ViewModelFactory.settingsLanguages())
        settings.append(settingItem3)
        
        self.dataHolder = ListDataHolder(data:Observable.just(settings).structured())
        
        self.title = "lbl_settingsHeaderTitle".localized()
    }
}
