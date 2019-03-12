//
//  GenericWebViewModel.swift
//  Sharengo
//
//  Created by Sharengo on 25/01/2019.
//  Copyright © 2019 CSGroup. All rights reserved.
//
import Foundation
import RxSwift
import Action


public enum GenericWebViewInput: SelectionInput {
}

public enum GenericWebViewOutput: SelectionInput {
    case empty
}

final class  GenericWebViewModel: ViewModelTypeSelectable {
    public var selection: Action<GenericWebViewInput, GenericWebViewOutput> = Action { input in
        return .just(.empty)
    }
}
