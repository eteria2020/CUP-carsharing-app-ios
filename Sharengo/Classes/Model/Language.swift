//
//  Language.swift
//  Sharengo
//
//  Created by Dedecube on 27/06/17.
//  Copyright © 2017 Dedecube. All rights reserved.
//

import Boomerang
import RxSwift

public class Language: ModelType {
    var title: String = ""
    
    init(title: String) {
        self.title = title
    }
}
