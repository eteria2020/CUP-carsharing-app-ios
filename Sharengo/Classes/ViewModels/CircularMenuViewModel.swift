//
//  CircularMenuViewModel.swift
//  Sharengo
//
//  Created by Dedecube on 19/05/17.
//  Copyright © 2017 Dedecube. All rights reserved.
//

import Foundation
import RxSwift
import Boomerang
import Action

enum CircularMenuType {
    case searchCars
    case feeds
    
    func getBackgroundBorderColor() -> UIColor {
        return Color.circularMenuBackgroundBorder.value
    }
    
    func getBackgroundBorderSize() -> CGFloat {
        return UIScreen.main.bounds.height*0.08
    }
    
    func getBackgroundViewColor() -> UIColor {
        return Color.circularMenuBackground.value
    }
    
    func getItems() -> [CircularMenuItem] {
        switch self {
        case .searchCars:
            return [CircularMenuItem(icon: "ic_referesh", input: .refresh),
                    CircularMenuItem(icon: "ic_center", input: .center),
                    CircularMenuItem(icon: "ic_compass", input: .compass),
                    CircularMenuItem(icon: "ic_compass", input: .compass),
            ]
        case .feeds:
            return [CircularMenuItem(icon: "ic_cars", input: .cars),
                    CircularMenuItem(icon: "ic_referesh", input: .refresh),
                    CircularMenuItem(icon: "ic_center", input: .center),
                    CircularMenuItem(icon: "ic_compass", input: .compass)
            ]
        }
    }
}

struct CircularMenuItem {
    let icon: String
    let input: CircularMenuInput
}

public enum CircularMenuInput: SelectionInput {
    case refresh
    case center
    case compass
    case cars
}

public enum CircularMenuOutput: SelectionInput {
    case empty
    case refresh
    case center
    case compass
    case cars
}

final class CircularMenuViewModel: ViewModelTypeSelectable {    
    let type: CircularMenuType
    public var selection: Action<CircularMenuInput, CircularMenuOutput> = Action { _ in
        return .just(.empty)
    }
    
    init(type: CircularMenuType) {
        self.type = type
        self.selection = Action { input in
            switch input {
            case .refresh:
                return .just(.refresh)
            case .center:
                return .just(.center)
            case .compass:
                return .just(.compass)
            case .cars:
                return .just(.cars)
            }
        }
    }
}
