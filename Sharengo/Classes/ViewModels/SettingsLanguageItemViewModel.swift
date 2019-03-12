//
//  SettingsLanguageItemViewModel.swift
//  Sharengo
//
//  Created by Dedecube on 27/06/17.
//  Copyright © 2017 Dedecube. All rights reserved.
//

import Foundation
import RxSwift


/**
 The Setting language item model provides data related to display content on the setting language item
 */
public final class SettingsLanguageItemViewModel : ItemViewModelType {
    /// ViewModel variable used to save data
    public var model:ItemViewModelType.Model
    /// ViewModel variable used to identify setting language item cell
    public var itemIdentifier:ListIdentifier = CollectionViewCell.settingsLanguage
    /// Variable used to save if the setting language item is selected or not
    public var selected: Bool = false
    /// Title of the setting item
    public var title: String?
    
    // MARK: - Init methods
    
    public init(model: Language) {
        self.model = model
        self.title = model.title.localized()
        self.selected = model.selected
    }
}
