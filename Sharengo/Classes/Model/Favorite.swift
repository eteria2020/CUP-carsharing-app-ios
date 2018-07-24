//
//  Favorite.swift
//  Sharengo
//
//  Created by Dedecube on 03/06/17.
//  Copyright © 2017 Dedecube. All rights reserved.
//

import Boomerang
import RxSwift
import Gloss
import CoreLocation

/**
 The Favourite model is used to represent empty favourites
 */
public class Favorite: ModelType {
    /// Text that has to be shown
    public var name: String?
    /// Empty favourite used when no favorite are memorized in the settings section
    public static var empty1:Favorite {
        return Favorite(name: "lbl_searchBarNoFavorites".localized())
    }
    /// Empty favourite used when user is in settings screen
    public static var empty2:Favorite {
        return Favorite(name: "lbl_favouritesNoFavorites".localized())
    }

    // MARK: - Init methods
    
    public init(name: String?) {
        self.name = name
    }
}
