//
//  MenuItem.swift
//  Sharengo
//
//  Created by Dedecube on 20/06/17.
//  Copyright © 2017 Dedecube. All rights reserved.
//

import Boomerang
import RxSwift

public class MenuItem: ModelType {
    var title: String = ""
    var icon: String = ""
    
    init(title: String, icon: String) {
        self.title = title
        self.icon = icon
    }
}
