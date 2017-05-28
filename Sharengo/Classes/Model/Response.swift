//
//  Response.swift
//
//  Created by Dedecube on 28/05/17.
//  Copyright © 2017 Dedecube. All rights reserved.
//

import Boomerang
import RxSwift
import Gloss

enum ResponseType {
    case cars
}

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
    var reason: String?
    var data: [JSON]?
    
    static var empty:Response {
        return Response()
    }
    
    init() {
    }
    
    required init?(json: JSON) {
        self.status = "status" <~~ json
        self.reason = "reason" <~~ json
        self.data = "data" <~~ json
    }
}
