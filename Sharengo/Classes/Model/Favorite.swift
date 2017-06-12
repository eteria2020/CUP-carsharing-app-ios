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

public class Favorite: ModelType {
    var name: String?
  
    init(name: String?) {
        self.name = name
    }
    
    static var empty:Favorite {
        return Favorite(name: "lbl_searchBarNoFavorites".localized())
    }
}
