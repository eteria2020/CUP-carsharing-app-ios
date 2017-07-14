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
    var date: String?
    var claim: String?
    var bottomText: String?
    var icon: UIImage?
    var color: UIColor
    var image: String?
    
    init(model: Feed) {
        self.model = model
        
        if model.advantage != nil
        {
            self.bottomText = String(format: "lbl_feedsItemExtendedBottom".localized(), model.title.uppercased(), model.date, model.subtitle, model.description, model.advantage!)
        }
        else
        {
            self.bottomText = String(format: "lbl_feedsItemBottom".localized(), model.title.uppercased(), model.date, model.subtitle, model.description)
        }
        
        self.claim = model.claim
        self.icon = UIImage(named: model.icon)
        self.color = UIColor(hexString: model.color)
        self.image = model.image
    }
}
