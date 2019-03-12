//
//  SignupViewModel.swift
//  Sharengo
//
//  Created by Dedecube on 13/06/17.
//  Copyright © 2017 Dedecube. All rights reserved.
//

import Foundation
import RxSwift

import Action

/**
 Enum that specifies selection input
 */
public enum SignupSelectionInput: SelectionInput {
    case signup
}

/**
 Enum that specifies selection output
 */
public enum SignupSelectionOutput: SelectionOutput {
    case signup
}

/**
 The Signup model provides data related to display content on signuip
 */
public final class SignupViewModel: ViewModelType {
    /// ViewModel variable used to save data
    public let stepsArray: [SignupStepView]
    /// Selection variable
    public lazy var selection:Action<SignupSelectionInput,SignupSelectionOutput> = Action { input in
        switch input {
        case .signup:
            return .just(.signup)
        }
    }
    
    // MARK: - Init methods
    
    public init() {
        var stepsArray = [SignupStepView]()
        let step1 = Bundle.main.loadNibNamed(ViewXib.signupStep.rawValue, owner: nil, options: nil)?.last as? SignupStepView
        step1?.bind(to: SignupStepViewModel(title: "lbl_signupStepTitle1", icon: "signup_01", description: "lbl_signupStepDescription1"))
        let step2 = Bundle.main.loadNibNamed(ViewXib.signupStep.rawValue, owner: nil, options: nil)?.last as? SignupStepView
        step2?.bind(to: SignupStepViewModel(title: "lbl_signupStepTitle2", icon: "signup_02", description: "lbl_signupStepDescription2"))
        let step3 = Bundle.main.loadNibNamed(ViewXib.signupStep.rawValue, owner: nil, options: nil)?.last as? SignupStepView
        step3?.bind(to: SignupStepViewModel(title: "lbl_signupStepTitle3", icon: "signup_03", description: "lbl_signupStepDescription3"))
        let step4 = Bundle.main.loadNibNamed(ViewXib.signupStep.rawValue, owner: nil, options: nil)?.last as? SignupStepView
        step4?.bind(to: SignupStepViewModel(title: "lbl_signupStepTitle4", icon: "signup_04", description: "lbl_signupStepDescription4"))
        stepsArray.append(step1!)
        stepsArray.append(step2!)
        stepsArray.append(step3!)
        stepsArray.append(step4!)
        self.stepsArray = stepsArray
    }
}
