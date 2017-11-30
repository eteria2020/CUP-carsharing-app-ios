//
//  MenuItemViewModel.swift
//  Sharengo
//
//  Created by Dedecube on 20/06/17.
//  Copyright © 2017 Dedecube. All rights reserved.
//

import Foundation
import RxSwift
import Boomerang

/**
 The Menu item model provides data related to display content on the menu item
 */
public class MenuItemViewModel : ItemViewModelType {
    /// ViewModel variable used to save data
    public var model:ItemViewModelType.Model
    /// ViewModel variable used to identify menu item cell
    public var itemIdentifier:ListIdentifier = CollectionViewCell.menu
    /// Title of the menu item
    public var title: String?
    /// Icon of the menu item
    public var icon: UIImage?

    // MARK: - Init methods
    
    public init(model: MenuItem) {
        self.model = model
        self.title = model.title.localized()
        self.icon = UIImage(named: model.icon)
    }
}
