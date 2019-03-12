//
//  Category.swift
//  Sharengo
//
//  Created by Dedecube on 13/07/17.
//  Copyright © 2017 Dedecube. All rights reserved.
//


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

/**
 The Category model is used to represent a category of feeds.
 */
public class Category: ModelType, Gloss.JSONDecodable {
    /// Unique identifier
    public var identifier: String = ""
    /// Title
    public var title: String = ""
    /// Icon
    public var icon: String = ""
    /// Gif path
    public var gif: String = ""
    /// Boolean that determine if Category is published or not
    public var published: Bool = false
    /// Category's color
    public var color: String = ""
    
    // MARK: - Init methods
    
    required public init?(json: JSON) {
        self.identifier = "tid" <~~ json ?? ""
        self.title = "name" <~~ json ?? ""
        self.gif = "media.videos.default.uri" <~~ json ?? ""
        self.icon = "media.images.image.uri" <~~ json ?? ""
        self.color = "appearance.color.rgb" <~~ json ?? ""
        if let published: String = "status.published" <~~ json {
            self.published = published.toBool() ?? false
        }
    }
}
