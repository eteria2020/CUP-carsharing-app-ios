//
//  SettingsLanguageItemViewModel.swift
//  Sharengo
//
//  Created by Dedecube on 27/06/17.
//  Copyright © 2017 Dedecube. All rights reserved.
//

import Foundation
import RxSwift
import Boomerang

final class SettingsLanguageItemViewModel : ItemViewModelType {
    var model:ItemViewModelType.Model
    var itemIdentifier:ListIdentifier = CollectionViewCell.settingsLanguage
    var selected: Bool = false
    var title: String?
    
    init(model: Language) {
        self.model = model
        self.title = model.title.localized()
        self.selected = model.selected
    }
}
