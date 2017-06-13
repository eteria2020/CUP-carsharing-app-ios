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
    fileprivate var view: UIView!
    
    var viewModel: SignupStepViewModel?
    
    // MARK: - ViewModel methods
    
    func bind(to viewModel: ViewModelType?) {
        guard let viewModel = viewModel as? SignupStepViewModel else {
            return
        }
        self.viewModel = viewModel
        xibSetup()
    
        self.lbl_title.text = viewModel.title
        self.icn_main.image = viewModel.icon
        self.lbl_description.text = viewModel.description
    }
    
    // MARK: - View methods
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    fileprivate func xibSetup() {
        view = loadViewFromNib()
        view.frame = bounds
        view.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]
        addSubview(view)
        self.layoutIfNeeded()
    }
    
    fileprivate func loadViewFromNib() -> UIView {
        let nib = ViewXib.signupStep.getNib()
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        return view
    }
}
