//
//  SignupStepView.swift
//  Sharengo
//
//  Created by Dedecube on 13/06/17.
//  Copyright © 2017 Dedecube. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Boomerang

class SignupStepView: UIView {
    @IBOutlet fileprivate weak var lbl_title: UILabel!
    @IBOutlet fileprivate weak var icn_main: UIImageView!
    @IBOutlet fileprivate weak var lbl_description: UILabel!
    
    var viewModel: SignupStepViewModel?
    
    // MARK: - ViewModel methods
    
    func bind(to viewModel: ViewModelType?) {
        guard let viewModel = viewModel as? SignupStepViewModel else {
            return
        }
        self.viewModel = viewModel
       
        self.lbl_title.styledText = viewModel.title
        self.icn_main.image = viewModel.icon
        self.lbl_description.styledText = viewModel.description
    }
}
