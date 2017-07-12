//
//  FeedItemViewModel.swift
//  Sharengo
//
//  Created by Fabrizio Infante on 12/07/17.
//  Copyright © 2017 Dedecube. All rights reserved.
//

import Foundation
import RxSwift
import Boomerang

final class FeedItemViewModel : ItemViewModelType {
    var model:ItemViewModelType.Model
    var itemIdentifier:ListIdentifier
    
    init(model: Feed) {
        self.model = model
    }
}
