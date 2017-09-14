//
//  GoogleResponse.swift
//
//  Created by Dedecube on 28/05/17.
//  Copyright © 2017 Dedecube. All rights reserved.
//

import Boomerang
import RxSwift
import Gloss

class GoogleResponse: ModelType, Decodable {
    var array_data: [JSON]?
    
    static var empty:Response {
        return Response()
    }
    
    init() {
    }
    
    required init?(json: JSON) {
        if let results: [JSON] = "results" <~~ json {
            self.array_data =  results
        }
        if let routes: [JSON] = "routes" <~~ json {
            self.array_data =  routes
        }
    }
}
