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
    case empty
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
        step1?.bind(to: SignupStepViewModel(title: "Aaa", icon: "mizzie_05_finecorsa", description: "BBB"))
        let step2 = Bundle.main.loadNibNamed(ViewXib.signupStep.rawValue, owner: nil, options: nil)?.last as? SignupStepView
        step2?.bind(to: SignupStepViewModel(title: "Aaa", icon: "mizzie_05_finecorsa", description: "BBB"))
        
        stepsArray.append(step1!)
        stepsArray.append(step2!)

        self.stepsArray = stepsArray
    }
    
    func signup()
    {
    }}
