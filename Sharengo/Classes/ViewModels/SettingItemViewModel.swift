//
//  SettingItemViewModel.swift
//  Sharengo
//
//  Created by Dedecube on 27/06/17.
//  Copyright © 2017 Dedecube. All rights reserved.
//

import Foundation
import RxSwift
import Boomerang

/**
 The Setting item model provides data related to display content on the setting item
 */
public final class SettingItemViewModel : ItemViewModelType {
    /// ViewModel variable used to save data
    public var model:ItemViewModelType.Model
    /// ViewModel variable used to identify setting item cell
    public var itemIdentifier:ListIdentifier = CollectionViewCell.setting
    /// Title of the setting item
    public var title: String?
    /// Icon of the setting item
    public var icon: UIImage?
    
    // MARK: - Init methods
    
    public init(model: Setting) {
        self.model = model
        self.title = model.title.localized()
        self.icon = UIImage(named: model.icon)
    }
}
