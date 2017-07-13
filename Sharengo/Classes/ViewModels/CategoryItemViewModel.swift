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
    var title: String
    var icon: UIImage?
    var published: Bool
    
    init(model: Category) {
        self.model = model
        
        self.title = model.title
        if let image = UIImage(named: model.icon)
        {
            self.icon = image
        }
        self.published = model.published
    }
}
