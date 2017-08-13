//
//  FeedAnnotation.swift
//
//  Created by Dedecube on 23/05/17.
//  Copyright © 2017 Dedecube. All rights reserved.
//

import UIKit
import MapKit
import GoogleMaps

/**
 FeedAnnotation class is the GMUClusterItem that application uses to show feed location (single pin or cluster)
 */
class FeedAnnotation: NSObject, GMUClusterItem {
    /// Variable used to save the position of the marker
    var position: CLLocationCoordinate2D
    /// Variable used to save the image to show in the marker
    var marker: UIImage
    /// Variable used to save the feed
    var feed: Feed
    
    // MARK: - Init methods
    
    public init(position: CLLocationCoordinate2D, feed: Feed) {
        self.position = position
        self.feed = feed
        self.marker = UIImage(named: "ic_puntatore-generico")!
        if let icon = feed.marker, let url = URL(string: icon) {
            do {
                let data = try Data(contentsOf: url)
                if let image = UIImage(data: data) {
                    var size = CGSize(width:38, height: 46)
                    if feed.sponsored {
                        size = CGSize(width: 46, height: 55)
                    }
                    UIGraphicsBeginImageContext(size)
                    let areaSize = CGRect(x: 0, y: 0, width: size.width, height: size.height)
                    image.draw(in: areaSize)
                    let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
                    UIGraphicsEndImageContext()
                    self.marker = newImage
                }
            } catch {
            }
        }
    }
}
