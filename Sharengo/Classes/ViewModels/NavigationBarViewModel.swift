//
//  NavigationBarViewModel.swift
//  Sharengo
//
//  Created by Dedecube on 19/05/17.
//  Copyright © 2017 Dedecube. All rights reserved.
//

import Foundation
import RxSwift

import Action

/**
 Enum that specifies navigation bar type and features related to it. These are:
 - items
 */
public enum NavigationBarItemType {
    case home
    case menu
    case empty
    
    public func getItem() -> NavigationBarItem {
        switch self {
        case .home:
            return NavigationBarItem(icon: "ic_arrow_back", input: .home)
        case .menu:
            return NavigationBarItem(icon: "ic_hambugeremenu", input: .menu)
        case .empty:
            return NavigationBarItem(icon: "", input: .empty)
        }
    }
}

/**
 Struct used for items
 */
public struct NavigationBarItem {
    /// Icon of the navigation bar item
    public let icon: String
    /// Selection input of the circular menu item
    public let input: NavigationBarInput
}

/**
 Enum that specifies selection input
 */
public enum NavigationBarInput: SelectionInput {
    case home
    case menu
    case empty
}

/**
 Enum that specifies selection output
 */
public enum NavigationBarOutput: SelectionInput {
    case empty
    case home
    case menu
}

/**
 The Navigation bar model provides data related to display content on the navigation bar
 */
public final class NavigationBarViewModel: ViewModelTypeSelectable {
    /// Left item of the navigation bar
    public let letfItem: NavigationBarItem
    /// Right item of the navigation bar
    public let rightItem: NavigationBarItem
    /// Selection variable
    public var selection: Action<NavigationBarInput, NavigationBarOutput> = Action { _ in
        return .just(.empty)
    }
    
    // MARK: - Init methods
    
    public init(leftItem: NavigationBarItem, rightItem: NavigationBarItem) {
        self.letfItem = leftItem
        self.rightItem = rightItem
        self.selection = Action { input in
            switch input {
            case .home:
                return .just(.home)
            case .menu:
                return .just(.menu)
            case .empty:
              return .just(.empty)
            }
            
        }
    }
}
