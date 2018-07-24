//
//  SettingsCityItemViewModel.swift
//  Sharengo
//
//  Created by Dedecube on 28/06/17.
//  Copyright © 2017 Dedecube. All rights reserved.
//

import Foundation
import RxSwift
import Boomerang

/**
 The Setting city item model provides data related to display content on the setting city item
 */
public class SettingsCityItemViewModel : ItemViewModelType {
    /// ViewModel variable used to save data
    public var model:ItemViewModelType.Model
    /// ViewModel variable used to identify setting city item cell
    public var itemIdentifier:ListIdentifier = CollectionViewCell.settingsCity
    /// Variable used to save if the setting city item is selected or not
    public var selected: Bool = false
    /// Title of the setting item
    public var title: String?
    /// Icon of the setting item
    public var icon: String?
    /// Icon of the setting item
    public var identifier: String?
    // MARK: - Init methods
    
    public init(model: City) {
        self.model = model
        self.title = model.title
        self.selected = model.selected
        self.icon = model.icon
        self.identifier = model.identifier
    }
}
