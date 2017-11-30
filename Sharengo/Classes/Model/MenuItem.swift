//
//  MenuItem.swift
//  Sharengo
//
//  Created by Dedecube on 20/06/17.
//  Copyright © 2017 Dedecube. All rights reserved.
//

import Boomerang
import RxSwift

/**
 The MenuItem model is used to represent singular item of menu
 */
public class MenuItem: ModelType {
    /// Title
    public var title: String = ""
    /// Icon
    public var icon: String = ""
    /// ViewModel related to this menu item
    public var viewModel: ViewModelType?
    
    // MARK: - Init methods
    
    public init(title: String, icon: String, viewModel: ViewModelType?) {
        self.title = title
        self.icon = icon
        self.viewModel = viewModel
    }
}
