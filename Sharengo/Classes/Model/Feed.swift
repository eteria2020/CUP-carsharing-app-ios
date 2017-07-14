//
//  Feed.swift
//  Sharengo
//
//  Created by Dedecube on 12/07/17.
//  Copyright © 2017 Dedecube. All rights reserved.
//

import Boomerang
import RxSwift
import Gloss

public class Feed: ModelType, Decodable {
    /*
    JSON response example:
    {
        "nid":"2",
        "title":"Offerta #2",
        "partner":
        {
            "tid":"4",
            "name":"Partner #2"
        },
        "category":
        {
            "tid":"1",
            "name":"Shopping",
            "media":
            {
                "images":
                {
                    "icon":
                    {
                        "uri":"http:\/\/universo-sharengo.thedigitalproject.it\/sites\/default\/files\/assets\/images\/icons\/sng-icona-shop-generica-100.png"
                    },
                    "marker":
                    {  
                        "uri":"http:\/\/universo-sharengo.thedigitalproject.it\/sites\/default\/files\/assets\/images\/markers\/puntatore-shop-generico_0.png"
                    }
                }
            }
        },
        "media":
        {
            "images":
            {
                "image":
                {
                    "uri":"http:\/\/universo-sharengo.thedigitalproject.it\/sites\/default\/files\/styles\/offers_events_640_340\/public\/assets\/images\/eventi-shop-sng-shopngo.jpg?itok=PH2laTNS"
                },
                "icon":
                {
                    "uri":"http:\/\/universo-sharengo.thedigitalproject.it\/sites\/default\/files\/assets\/images\/markers\/puntatore-shop-sng.png"
                }
            }
        },
        "appearance":
        {
            "color":
            {
                "rgb":"#954bb5",
                "enforce":"false"
            }
        },
        "informations":
        {
            "date":
            {
                "default":"31-07-2017 23:59",
                "friendly":"Luned\u00ec 31 Luglio 2017"
            },
            "city":
            {
                "tid":"5",
                "name":"Milano"
            },
            "location":"Sul piazzale",
            "address":
            {
                "friendly":"Piazzale Lagosta",
                "lat":"45.4892798",
                "lng":"9.191393100000028"
            },
            "advantage_top":"Nessun vantaggio TOP",
            "advantage_bottom":"Nessun vantaggio BOTTOM",
            "abstract":"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.","description":"Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo. Nemo enim ipsam voluptatem quia voluptas sit aspernatur aut odit aut fugit, sed quia consequuntur magni dolores eos qui ratione voluptatem sequi nesciunt. Neque porro quisquam est, qui dolorem ipsum quia dolor sit amet, consectetur, adipisci velit, sed quia non numquam eius modi tempora incidunt ut labore et dolore magnam aliquam quaerat voluptatem. Ut enim ad minima veniam, quis nostrum exercitationem ullam corporis suscipit laboriosam, nisi ut aliquid ex ea commodi consequatur? Quis autem vel eum iure reprehenderit qui in ea voluptate velit esse quam nihil molestiae consequatur, vel illum qui dolorem eum fugiat quo voluptas nulla pariatur?"
            }
     }
    */
 
    var identifier: String = ""
    var title: String = ""
    var subtitle: String = ""
    var description: String = ""
    var icon: String = ""
    var claim: String?
    var date: String = ""
    var advantage: String?
    var color: String = ""
    var image: String = ""
    
    required public init?(json: JSON) {
        // TODO: manca la descrizione
        self.identifier = "tid" <~~ json ?? ""
        self.title = "title" <~~ json ?? ""
        self.subtitle = "informations.abstract" <~~ json ?? ""
        self.date = "informations.date.friendly" <~~ json ?? ""
        self.claim = "informations.advantage_top" <~~ json ?? ""
        self.advantage = "informations.advantage_bottom" <~~ json ?? ""
        self.icon = "category.media.images.image.uri" <~~ json ?? ""
        self.color = "category.appearance.color.rgb" <~~ json ?? ""
        self.image = "media.images.image.uri" <~~ json ?? ""
    }
}
