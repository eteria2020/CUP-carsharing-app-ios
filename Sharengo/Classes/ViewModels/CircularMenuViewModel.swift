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

/**
 Enum that specifies circular menu type and features related to it. These are:
 - background border color
 - background border size
 - background color
 - items
 */
public enum CircularMenuType {
    case searchCars
    case feeds
    
    public func getBackgroundBorderColor() -> UIColor {
        return Color.circularMenuBackgroundBorder.value
    }
    
    public func getBackgroundBorderSize() -> CGFloat {
        return UIScreen.main.bounds.height*0.08
    }
    
    public func getBackgroundViewColor() -> UIColor {
        return Color.circularMenuBackground.value
    }
    
    public func getItems() -> [CircularMenuItem] {
        switch self {
        case .searchCars:
            return [CircularMenuItem(icon: "ic_referesh", input: .refresh),
                    CircularMenuItem(icon: "ic_center", input: .center),
                    CircularMenuItem(icon: "ic_compass", input: .compass)
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

/**
 Struct used for items
 */
public struct CircularMenuItem {
    /// Icon of the circular menu item
    public let icon: String
    /// Selection input of the circular menu item
    public let input: CircularMenuInput
}

/**
 Enum that specifies selection input
 */
public enum CircularMenuInput: SelectionInput {
    case refresh
    case center
    case compass
    case cars
}

/**
 Enum that specifies selection output
 */
public enum CircularMenuOutput: SelectionInput {
    case empty
    case refresh
    case center
    case compass
    case cars
}

/**
 The Circular menu model provides data related to display content on the circular menu
 */
public class CircularMenuViewModel: ViewModelTypeSelectable {
    /// Type of the circular menu
    public let type: CircularMenuType
    /// Selection variable
    public var selection: Action<CircularMenuInput, CircularMenuOutput> = Action { _ in
        return .just(.empty)
    }
    
    // MARK: - Init methods
    
    public init(type: CircularMenuType) {
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
