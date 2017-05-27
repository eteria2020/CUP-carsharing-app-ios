//
//  NavigationBarViewModel.swift
//  Sharengo
//
//  Created by Dedecube on 19/05/17.
//  Copyright © 2017 Dedecube. All rights reserved.
//

import Foundation
import RxSwift
import Boomerang
import Action

enum NavigationBarItemType {
    case home
    case menu
    
    func getItem() -> NavigationBarItem {
        switch self {
        case .home:
            return NavigationBarItem(icon: "ic_menu", input: .home)
        case .menu:
            return NavigationBarItem(icon: "ic_hambugeremenu", input: .menu)
        }
    }
}

struct NavigationBarItem {
    let icon: String
    let input: NavigationBarInput
}

public enum NavigationBarInput: SelectionInput {
    case home
    case menu
}

public enum NavigationBarOutput: SelectionInput {
    case empty
}

final class NavigationBarViewModel: ViewModelTypeSelectable {
    let letfItem: NavigationBarItem
    let rightItem: NavigationBarItem
    public var selection: Action<NavigationBarInput, NavigationBarOutput> = Action { _ in
        return .just(.empty)
    }
    
    init(leftItem: NavigationBarItem, rightItem: NavigationBarItem) {
        self.letfItem = leftItem
        self.rightItem = rightItem
        self.selection = Action { input in
            switch input {
            case .home:
                print("Go to home")
                break
            case .menu:
                print("Open menu")
                break
            }
            return .just(.empty)
        }
    }
}
