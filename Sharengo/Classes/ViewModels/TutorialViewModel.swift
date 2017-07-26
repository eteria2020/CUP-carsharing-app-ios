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
    let steps = [TutorialStep(stepNumber: 0, image: "img_tutorialStep1".localized()),
                 TutorialStep(stepNumber: 1, image: "img_tutorialStep2".localized()),
                 TutorialStep(stepNumber: 2, image: "img_tutorialStep3".localized())]
    
    init()
    {
    }
}
