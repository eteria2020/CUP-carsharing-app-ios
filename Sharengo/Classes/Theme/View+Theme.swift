//
//  View+Theme.swift
//  Sharengo
//
//  Created by Dedecube on 19/05/17.
//  Copyright © 2017 Dedecube. All rights reserved.
//

import UIKit

enum ViewXib: String {
    case navigationBar = "NavigationBarView"
    case circularMenu = "CircularMenuView"
    case carPopup = "CarPopupView"
    
    func getNib() -> UINib {
        let bundle = Bundle.main
        return UINib(nibName: self.rawValue, bundle: bundle)
    }
}
