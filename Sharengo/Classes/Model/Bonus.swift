//
//  RouteStepRouteStep.swift
//  Sharengo
//
//  Created by Dedecube on 06/06/17.
//  Copyright © 2017 Dedecube. All rights reserved.
//


import RxSwift
import Gloss

/**
 The Bonus model is used to represent a singular bonus.
 */
public class Bonus: ModelType, Gloss.JSONDecodable {
    /// Bonus type
    public var type: String = ""
    /// Value of Bonus
    public var value: Int = 0
    /// Boolean that determine if bonus is active or not
    public var status: Bool = false
  
    // MARK: - Init methods
    
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
