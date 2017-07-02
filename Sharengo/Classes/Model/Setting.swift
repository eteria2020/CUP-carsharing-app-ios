//
//  Setting.swift
//  Sharengo
//
//  Created by Dedecube on 27/06/17.
//  Copyright © 2017 Dedecube. All rights reserved.
//

import Boomerang
import RxSwift

public class Setting: ModelType {
    var title: String = ""
    var icon: String = ""
    var viewModel: ViewModelType?
    
    init(title: String, icon: String, viewModel: ViewModelType?) {
        self.title = title
        self.icon = icon
        self.viewModel = viewModel
    }
}
