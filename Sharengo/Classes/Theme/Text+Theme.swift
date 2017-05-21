//
//  Text+Theme.swift
//  Sharengo
//
//  Created by Dedecube on 21/05/17.
//  Copyright © 2017 Dedecube. All rights reserved.
//

import UIKit
import BonMot

public protocol TextStyleType {
    var name:String {get}
    var style:StringStyle {get}
}

public extension NamedStyles {
    func registerStyle(style:TextStyleType) {
        self.registerStyle(forName: style.name, style: style.style)
    }
}

enum TextStyle: String, TextStyleType {
    // SearchBar:
    case searchBarTextField = "searchBarTextField"
    
    static var all:[TextStyle] {
        return [
            .searchBarTextField,
        ]
    }
    
    var name:String {
        return self.rawValue
    }
    
    var style:StringStyle {
        return { () -> StringStyle in
            switch self {
            case .searchBarTextField:
                return StringStyle(.font(Font.searchBarTextField.value), .color(Color.searchBarTextField.value), .alignment(.center))
            }
        }().byAdding(.lineBreakMode(.byTruncatingTail))
    }
    
    static func setup() {
        all.forEach { NamedStyles.shared.registerStyle(style: $0) }
    }
}
