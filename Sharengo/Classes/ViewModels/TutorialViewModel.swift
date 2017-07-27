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
    let steps = [TutorialStep(stepNumber: 0, image: "tutorial_1".localized()),
                 TutorialStep(stepNumber: 1, image: "tutorial_2".localized()),
                 TutorialStep(stepNumber: 2, image: "tutorial_3".localized()),
                 TutorialStep(stepNumber: 3, image: "tutorial_4".localized()),
                 TutorialStep(stepNumber: 4, image: "tutorial_5".localized()),
                 TutorialStep(stepNumber: 5, image: "tutorial_6".localized()),
                 TutorialStep(stepNumber: 6, image: "tutorial_7".localized()),
                 TutorialStep(stepNumber: 7, image: "tutorial_8".localized())]
    
    init()
    {
    }
}
