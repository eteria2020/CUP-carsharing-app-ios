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

final class SettingsCityItemViewModel : ItemViewModelType {
    var model:ItemViewModelType.Model
    var itemIdentifier:ListIdentifier = CollectionViewCell.settingsCity
    var selected: Bool = false
    var title: String?
    var icon: String?
    
    init(model: City) {
        self.model = model
        self.title = model.title.localized()
        self.selected = model.selected
        self.icon = model.icon
    }
}
