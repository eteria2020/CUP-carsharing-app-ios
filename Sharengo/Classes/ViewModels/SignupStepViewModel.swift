//
//  SignupStepViewModel.swift
//  Sharengo
//
//  Created by Dedecube on 13/06/17.
//  Copyright © 2017 Dedecube. All rights reserved.
//

import Foundation
import RxSwift
import Boomerang

final class SignupStepViewModel: ViewModelType {
    var title: String = ""
    var icon: UIImage = UIImage()
    var description: String = ""
    
    init(title: String, icon: String, description: String) {
        self.title = title.localized()
        self.icon = UIImage(named: icon) ?? UIImage()
        self.description = description.localized()
    }
}
