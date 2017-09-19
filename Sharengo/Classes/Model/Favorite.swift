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
 The Favourite  model is used to represent user's favourites.
 */
public class Favorite: ModelType {
    /// Favourite's name
    public var name: String?
    /// Empty var of type Favourite
    public static var empty1:Favorite {
        return Favorite(name: "lbl_searchBarNoFavorites".localized())
    }
    /// Empty var of type Favourite
    public static var empty2:Favorite {
        return Favorite(name: "lbl_favouritesNoFavorites".localized())
    }

    // MARK: - Init methods
    
    public init(name: String?) {
        self.name = name
    }
}
