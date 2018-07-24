//
//  SettingsNotificationsViewModel.swift
//  Sharengo
//
//  Created by Sharengo on 24/07/2018.
//  Copyright © 2018 CSGroup. All rights reserved.
//

import Foundation
import RxSwift
import Boomerang
import Action
import KeychainSwift

public enum SettingsNotificationsSelectionInput : SelectionInput {
    case item(IndexPath)
}

public enum SettingsNotificationsSelectionOutput : SelectionOutput {
    case empty
}

public final class SettingsNotificationsViewModel : ListViewModelType, ViewModelTypeSelectable
{
    fileprivate var resultsDispose: DisposeBag?
    /// ViewModel variable used to save data
    public var dataHolder: ListDataHolderType = ListDataHolder.empty
    /// Variable used to save title
    public var title = ""
    /// Variable used to save next screen that has to be opened after login
    public var nextViewModel: ViewModelType?
    /// Selection variable
    public lazy var selection:Action<SettingsNotificationsSelectionInput, SettingsNotificationsSelectionOutput> = Action { input in
        return .empty()
    }
    
    public func itemViewModel(fromModel model: ModelType) -> ItemViewModelType? {
        return nil
    }
    
    public init() {
    }
}
