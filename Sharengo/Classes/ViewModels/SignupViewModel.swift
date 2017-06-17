//
//  SignupViewModel.swift
//  Sharengo
//
//  Created by Dedecube on 13/06/17.
//  Copyright © 2017 Dedecube. All rights reserved.
//

import Foundation
import RxSwift
import Boomerang
import Action

enum SignupSelectionInput: SelectionInput {
    case signup
}

enum SignupSelectionOutput: SelectionOutput {
    case signup
}

final class SignupViewModel: ViewModelType {
    lazy var selection:Action<SignupSelectionInput,SignupSelectionOutput> = Action { input in
        switch input {
        case .signup:
            return .just(.signup)
        }
    }
    
    let stepsArray: [SignupStepView]

    init() {
        var stepsArray = [SignupStepView]()
        let step1 = Bundle.main.loadNibNamed(ViewXib.signupStep.rawValue, owner: nil, options: nil)?.last as? SignupStepView
        step1?.bind(to: SignupStepViewModel(title: "lbl_signupStepTitle1", icon: "mizzie_05_finecorsa", description: "lbl_signupStepDescription1"))
        let step2 = Bundle.main.loadNibNamed(ViewXib.signupStep.rawValue, owner: nil, options: nil)?.last as? SignupStepView
        step2?.bind(to: SignupStepViewModel(title: "lbl_signupStepTitle2", icon: "mizzie_05_finecorsa", description: "lbl_signupStepDescription2"))
        let step3 = Bundle.main.loadNibNamed(ViewXib.signupStep.rawValue, owner: nil, options: nil)?.last as? SignupStepView
        step3?.bind(to: SignupStepViewModel(title: "lbl_signupStepTitle3", icon: "mizzie_05_finecorsa", description: "lbl_signupStepDescription3"))
        let step4 = Bundle.main.loadNibNamed(ViewXib.signupStep.rawValue, owner: nil, options: nil)?.last as? SignupStepView
        step4?.bind(to: SignupStepViewModel(title: "lbl_signupStepTitle4", icon: "mizzie_05_finecorsa", description: "lbl_signupStepDescription4"))
        stepsArray.append(step1!)
        stepsArray.append(step2!)
        stepsArray.append(step3!)
        stepsArray.append(step4!)
        self.stepsArray = stepsArray
    }
    
    func signup() { }
}
