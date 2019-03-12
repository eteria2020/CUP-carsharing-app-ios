//
//  Setting.swift
//  Sharengo
//
//  Created by Dedecube on 27/06/17.
//  Copyright © 2017 Dedecube. All rights reserved.
//


import RxSwift

/**
 The Setting  model is used to represent singular setting.
 */
public class Setting: ModelType {
    /// Title
    public var title: String = ""
    /// Icon
    public var icon: String = ""
    /// ViewModel connected to this setting
    public var viewModel: ViewModelType?
    
    // MARK: - Init methods
    
    public init(title: String, icon: String, viewModel: ViewModelType?) {
        self.title = title
        self.icon = icon
        self.viewModel = viewModel
    }
}
