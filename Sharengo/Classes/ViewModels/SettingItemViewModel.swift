//
//  SettingsViewController.swift
//  Sharengo
//
//  Created by Dedecube on 20/06/17.
//  Copyright © 2017 Dedecube. All rights reserved.
//

import Foundation
import RxSwift
import Boomerang

final class SettingItemViewModel : ItemViewModelType {
    var model:ItemViewModelType.Model
    var itemIdentifier:ListIdentifier
    
    init(model: Setting) {
        self.model = model
    }
}
