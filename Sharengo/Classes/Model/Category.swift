//
//  Category.swift
//  Sharengo
//
//  Created by Dedecube on 13/07/17.
//  Copyright © 2017 Dedecube. All rights reserved.
//

import Boomerang
import RxSwift
import Gloss

extension String {
    func toBool() -> Bool? {
        switch self {
        case "True", "true", "yes", "1":
            return true
        case "False", "false", "no", "0":
            return false
        default:
            return nil
        }
    }
}

public class Category: ModelType, Decodable {
    /*
    JSON response example:
    {
        "tid":"1",
        "name":"Shopping",
        "status":
        {
            "published":"1"
        },
        "media":
        {
            "images":
            {
                "marker":
                {
                    "uri":"http:\/\/universo-sharengo.thedigitalproject.it\/sites\/default\/files\/assets\/images\/markers\/puntatore-shop-generico_0.png"
                },
                "icon":
                {
                    "uri":"http:\/\/universo-sharengo.thedigitalproject.it\/sites\/default\/files\/assets\/images\/icons\/sng-icona-shop-generica-100.png"
                },
                "image":
                {
                    "uri":"http:\/\/universo-sharengo.thedigitalproject.it\/sites\/default\/files\/assets\/images\/sng-icona-shop-sng-100.png"
                }
            },
            "videos":
            {
                "default":
                {
                    "uri":"http:\/\/universo-sharengo.thedigitalproject.it\/sites\/default\/files\/assets\/videos\/video_demo.mp4"
                }
            }
        },
        "appearance":
        {
            "color":
            {
                "rgb":"#3aa652"
            }
        }
    }
    */
    
    var identifier: String = ""
    var title: String = ""
    var icon: String = ""
    var published: Bool = false
    
    required public init?(json: JSON) {
        // TODO: caricare il colore
        // TODO: caricare la gif invece dell'immagine
        self.identifier = "tid" <~~ json ?? ""
        self.title = "name" <~~ json ?? ""
        self.icon = "media.images.image.uri" <~~ json ?? ""
        if let published: String = "status.published" <~~ json {
            self.published = published.toBool() ?? false
        }
    }
}
