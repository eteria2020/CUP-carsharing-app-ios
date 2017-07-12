//
//  FeedItemViewModel.swift
//  Sharengo
//
//  Created by Dedecube on 12/07/17.
//  Copyright © 2017 Dedecube. All rights reserved.
//

import Foundation
import RxSwift
import Boomerang

final class FeedItemViewModel : ItemViewModelType {
    var model:ItemViewModelType.Model
    var itemIdentifier:ListIdentifier = CollectionViewCell.feed
    var title: String?
    var subtitle: String?
    var description: String?
    var claim: String?
    var date: String?
    var advantage: String?
    var icon: UIImage?
    
    init(model: Feed) {
        self.model = model
        self.title = model.title
        self.subtitle = model.subtitle
        self.description = model.description
        self.claim = model.claim
        self.date = model.date
        self.advantage = model.advantage
        self.icon = UIImage(named: model.icon)
    }
}
