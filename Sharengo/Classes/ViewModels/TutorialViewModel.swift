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

public enum TutorialInput: SelectionInput {
    case empty
}

public enum TutorialOutput: SelectionInput {
    case empty
}

struct TutorialStep {
    var stepNumber: Int
    var image: String
}

final class TutorialViewModel: ViewModelTypeSelectable {
    public var selection: Action<TutorialInput, TutorialOutput> = Action { _ in
        return .just(.empty)
    }
    var steps: [TutorialStep] = []
    
    init()
    {
        switch Device().diagonal {
        case 3.5:
            steps = [TutorialStep(stepNumber: 0, image: "tutorial_640x960_01".localized()),
                     TutorialStep(stepNumber: 1, image: "tutorial_640x960_02".localized()),
                     TutorialStep(stepNumber: 2, image: "tutorial_640x960_03".localized()),
                     TutorialStep(stepNumber: 3, image: "tutorial_640x960_04".localized()),
                     TutorialStep(stepNumber: 4, image: "tutorial_640x960_05".localized()),
                     TutorialStep(stepNumber: 5, image: "tutorial_640x960_06".localized()),
                     TutorialStep(stepNumber: 6, image: "tutorial_640x960_07".localized()),
                     TutorialStep(stepNumber: 7, image: "tutorial_640x960_08".localized())]
        default:
            steps = [TutorialStep(stepNumber: 0, image: "tutorial_01".localized()),
                     TutorialStep(stepNumber: 1, image: "tutorial_02".localized()),
                     TutorialStep(stepNumber: 2, image: "tutorial_03".localized()),
                     TutorialStep(stepNumber: 3, image: "tutorial_04".localized()),
                     TutorialStep(stepNumber: 4, image: "tutorial_05".localized()),
                     TutorialStep(stepNumber: 5, image: "tutorial_06".localized()),
                     TutorialStep(stepNumber: 6, image: "tutorial_07".localized()),
                     TutorialStep(stepNumber: 7, image: "tutorial_08".localized())]
        }
    }
}
