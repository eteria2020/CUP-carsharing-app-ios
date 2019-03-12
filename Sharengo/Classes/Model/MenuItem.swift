//
//  MenuItem.swift
//  Sharengo
//
//  Created by Dedecube on 20/06/17.
//  Copyright © 2017 Dedecube. All rights reserved.
//


import RxSwift

/**
 The MenuItem  model is used to represent singular item of Menu.
 */
public class MenuItem: ModelType {
    /// Title
    public var title: String = ""
    /// Icon
    var icon: String = ""
    /// ViewModel of connected section
    var viewModel: ViewModelType?
    
    // MARK: - Init methods
    
    init(title: String, icon: String, viewModel: ViewModelType?) {
        self.title = title
        self.icon = icon
        self.viewModel = viewModel
    }
}
