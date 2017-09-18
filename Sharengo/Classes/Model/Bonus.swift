//
//  RouteStepRouteStep.swift
//  Sharengo
//
//  Created by Dedecube on 06/06/17.
//  Copyright © 2017 Dedecube. All rights reserved.
//

import Boomerang
import RxSwift
import Gloss

public class Bonus: ModelType, Decodable {
    
    var type: String = ""
    var value: Int = 0
    var status: Bool = false
  
    required public init?(json: JSON) {
        if let t: String = "type" <~~ json {
            type = t
        }
        if let v: Int = "value" <~~ json {
            value = v
        }
        if let s: Bool = "status" <~~ json {
            status = s
        }
    }
}
