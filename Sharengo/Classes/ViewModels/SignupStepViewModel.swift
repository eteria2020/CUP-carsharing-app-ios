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

/**
 The Signup step model provides data related to display content on the signup step item
 */
public class SignupStepViewModel: ViewModelType {
    /// Title of the signup step item
    var title: String = ""
    /// Image of the signup step item
    var icon: UIImage = UIImage()
    /// Description of the signup step item
    var description: String = ""
    
    // MARK: - Init methods
    
    public init(title: String, icon: String, description: String) {
        self.title = title.localized()
        self.icon = UIImage(named: icon) ?? UIImage()
        self.description = description.localized()
    }
}
