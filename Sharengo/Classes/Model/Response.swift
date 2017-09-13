//
//  Response.swift
//
//  Created by Dedecube on 28/05/17.
//  Copyright © 2017 Dedecube. All rights reserved.
//

import Boomerang
import RxSwift
import Gloss

class Response: ModelType, Decodable {
    /*
    JSON response example:
    {
        "status":200,
        "reason":"No cars found",
        "data":null,
        "time":1495966726
    }
    */
    
    var status: Int?
    var status_bool: Bool?
    var reason: String?
    var code: String?
    var msg: String?
    var array_data: [JSON]?
    var dic_data: JSON?
    
    static var empty:Response {
        return Response()
    }
    
    init() {
    }
    
    required init?(json: JSON) {
        self.status = "status" <~~ json
        self.status_bool = "status" <~~ json
        self.reason = "reason" <~~ json
        self.code = "code" <~~ json
        self.msg = "msg" <~~ json
        self.array_data =  "data" <~~ json
        self.dic_data = "data" <~~ json
        if let results: [JSON] = "results" <~~ json {
            self.array_data =  results
        }
        if let routes: [JSON] = "routes.legs.steps" <~~ json {
            self.array_data =  routes
        }
    }
}
