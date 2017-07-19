//
//  CategoryItemViewModel.swift
//  Sharengo
//
//  Created by Dedecube on 13/07/17.
//  Copyright © 2017 Dedecube. All rights reserved.
//

import Foundation
import RxSwift
import Boomerang

final class CategoryItemViewModel : ItemViewModelType {
    var model:ItemViewModelType.Model
    var itemIdentifier:ListIdentifier = CollectionViewCell.category
    var title: String?
    var icon: String?
    var gif: String?
    var published: Bool
    var color: UIColor
    
    init(model: Category) {
        self.model = model
        self.title = model.title
        self.icon = model.icon
        self.gif = model.gif
        self.published = model.published
        self.color = UIColor(hexString: model.color)
    }
}
