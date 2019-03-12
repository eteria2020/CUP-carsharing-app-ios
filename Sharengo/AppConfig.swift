//
//  AppConfig.swift
//  Sharengo
//
//  Created by sharengo on 08/05/18.
//  Copyright © 2018 CSGroup. All rights reserved.
//


import RxSwift
import Gloss
import Foundation

public class AppConfig: ModelType,Gloss.JSONDecodable {
    
    public var config_key: String?
    
    public var config_value: String?
    
    
    public init() {
    }
    
    public required init?(json: JSON) {
        self.config_key = "config_key" <~~ json
        self.config_value = "config_value" <~~ json
       
    }
}

