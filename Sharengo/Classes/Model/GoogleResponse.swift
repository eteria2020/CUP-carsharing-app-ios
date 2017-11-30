//
//  GoogleResponse.swift
//
//  Created by Dedecube on 28/05/17.
//  Copyright © 2017 Dedecube. All rights reserved.
//

import Boomerang
import RxSwift
import Gloss

/**
 The Google Response model is used to convert api response from Google Servers in an object that has useful data
 */
public class GoogleResponse: ModelType, Decodable {
    /// Content of data as array
    public var array_data: [JSON]?
    
    // MARK: - Init methods
    
    public init() {
    }
    
    public required init?(json: JSON) {
        if let results: [JSON] = "results" <~~ json {
            self.array_data =  results
        }
        if let routes: [JSON] = "routes" <~~ json {
            self.array_data =  routes
        }
    }
}
