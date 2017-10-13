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

/**
 The CategoryViewModel provides data related to display content on feed collection view cell
 */
public class CategoryItemViewModel : ItemViewModelType {
    /// ViewModel variable used to save data
    public var model:ItemViewModelType.Model
    /// ViewModel variable used to identify favourite item cell
    public var itemIdentifier:ListIdentifier = CollectionViewCell.category
    /// Category title
    public var title: String?
    /// Category icon
    public var icon: String?
    /// Category icon (gif)
    public var gif: String?
    /// Boolean that determine if category is published or not
    public var published: Bool
    /// Category color
    public var color: UIColor
    
    // MARK: - Init methods
    
    public init(model: Category) {
        self.model = model
        self.title = model.title
        self.icon = model.icon
        self.gif = model.gif
        self.published = model.published
        self.color = UIColor(hexString: model.color)
    }
}
