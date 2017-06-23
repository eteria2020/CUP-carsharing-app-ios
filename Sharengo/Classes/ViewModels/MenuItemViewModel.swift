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

final class MenuItemViewModel : ItemViewModelType {
    var model:ItemViewModelType.Model
    var itemIdentifier:ListIdentifier = CollectionViewCell.menu
    var title: String?
    var icon: UIImage?

    init(model: MenuItem) {
        self.model = model
        self.title = model.title.localized()
        self.icon = UIImage(named: model.icon)
    }
}
