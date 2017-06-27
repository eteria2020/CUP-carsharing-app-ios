//
//  SettingsLanguageItemViewModel.swift
//  Sharengo
//
//  Created by Fabrizio Infante on 27/06/17.
//  Copyright © 2017 Dedecube. All rights reserved.
//

import Foundation
import RxSwift
import Boomerang

final class SettingsLanguageItemViewModel : ItemViewModelType {
    var model:ItemViewModelType.Model
    var itemIdentifier:ListIdentifier
    
    init(model: SettingsLanguage) {
        self.model = model
    }
}
