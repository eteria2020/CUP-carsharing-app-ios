//
//  TutorialViewModel.swift
//  Sharengo
//
//  Created by Dedecube on 26/07/17.
//  Copyright © 2017 Dedecube. All rights reserved.
//

import Foundation
import RxSwift
import Action
import Boomerang
import DeviceKit

/**
 Enum that specifies selection input
 */
public enum TutorialInput: SelectionInput {
    case empty
}

/**
 Enum that specifies selection output
 */
public enum TutorialOutput: SelectionInput {
    case empty
}

/**
 Struct with step's properties
 */
public struct TutorialStep {
    var stepNumber: Int
    var image: String
}

/**
 The TutorialViewModel provides data related to display tutorial steps to user
 */
public class TutorialViewModel: ViewModelTypeSelectable {
    /// Selection variable
    public var selection: Action<TutorialInput, TutorialOutput> = Action { _ in
        return .just(.empty)
    }
    /// Array of steps
    public var steps: [TutorialStep] = []
    
    // MARK: - Init methods
    
    public required init()
    {
        switch Device().diagonal {
        case 3.5:
            steps = [TutorialStep(stepNumber: 0, image: "img_tutorial640x960_01".localized()),
                     TutorialStep(stepNumber: 1, image: "img_tutorial640x960_02".localized()),
                     TutorialStep(stepNumber: 2, image: "img_tutorial640x960_03".localized()),
                     TutorialStep(stepNumber: 3, image: "img_tutorial640x960_04".localized()),
                     TutorialStep(stepNumber: 4, image: "img_tutorial640x960_05".localized()),
                     TutorialStep(stepNumber: 5, image: "img_tutorial640x960_06".localized()),
                     TutorialStep(stepNumber: 6, image: "img_tutorial640x960_07".localized()),
                     TutorialStep(stepNumber: 7, image: "img_tutorial640x960_08".localized())]
        default:
            steps = [TutorialStep(stepNumber: 0, image: "img_tutorial01".localized()),
                     TutorialStep(stepNumber: 1, image: "img_tutorial02".localized()),
                     TutorialStep(stepNumber: 2, image: "img_tutorial03".localized()),
                     TutorialStep(stepNumber: 3, image: "img_tutorial04".localized()),
                     TutorialStep(stepNumber: 4, image: "img_tutorial05".localized()),
                     TutorialStep(stepNumber: 5, image: "img_tutorial06".localized()),
                     TutorialStep(stepNumber: 6, image: "img_tutorial07".localized()),
                     TutorialStep(stepNumber: 7, image: "img_tutorial08".localized())]
        }
    }
}
