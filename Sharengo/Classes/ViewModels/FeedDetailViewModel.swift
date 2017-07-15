//
//  FeedDetailViewModel.swift
//  Sharengo
//
//  Created by Dedecube on 14/07/17.
//  Copyright © 2017 Dedecube. All rights reserved.
//

import Foundation
import RxSwift
import Boomerang
import Action

final class FeedDetailViewModel: ViewModelType {
    var model:ItemViewModelType.Model
    var title: String?
    var date: String?
    var claim: String?
    var bottomText: String?
    var icon: String?
    var color: UIColor
    var advantageColor: UIColor
    var image: String?

    init(model: Feed) {
        self.model = model
        
        if model.advantage != nil && model.advantage?.isEmpty == false
        {
            self.bottomText = String(format: "lbl_feedDetailExtendedBottom".localized(), model.categoryTitle.uppercased(), model.date, model.title, model.subtitle, model.advantage!, model.description)
        }
        else
        {
            self.bottomText = String(format: "lbl_feedDetailBottom".localized(), model.categoryTitle.uppercased(), model.date, model.title, model.subtitle, model.description)
        }
        
        self.title = model.categoryTitle.uppercased()
        self.claim = model.claim
        self.icon = model.icon
        self.color = UIColor(hexString: model.color)
        self.image = model.image
        
        if model.forceColor {
            advantageColor = UIColor(hexString: model.color)
        } else {
            advantageColor = UIColor(hexString: "#888888")
        }
    }
}
