//
//  View+Theme.swift
//  Sharengo
//
//  Created by Dedecube on 19/05/17.
//  Copyright © 2017 Dedecube. All rights reserved.
//

import UIKit

enum ViewXib: String {
    case circularMenu = "CircularMenuView"
    
    func getNib() -> UINib {
        let bundle = Bundle.main
        return UINib(nibName: self.rawValue, bundle: bundle)
    }
}
