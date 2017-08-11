//
//  CityAnnotation.swift
//
//  Created by Dedecube on 05/06/17.
//  Copyright © 2017 Dedecube. All rights reserved.
//

import UIKit
import MapKit
import GoogleMaps

class CityAnnotation: GMSMarker {
    var city: City?
    lazy var image: UIImage = self.getImage()
    
    // MARK: - Lazy methods
    
    func getImage() -> UIImage {
        if let icon = self.city?.icon,
            let url = URL(string: icon)
        {
            do {
                let data = try Data(contentsOf: url)
                if let image = UIImage(data: data) {
                    let bottomImage = UIImage(named: "ic_cluster")!
                    let topImage = image.tinted(ColorBrand.green.value)
                    
                    let size = CGSize(width: bottomImage.size.width, height: bottomImage.size.height)
                    UIGraphicsBeginImageContext(size)
                    
                    let areaSize = CGRect(x: 0, y: 0, width: size.width, height: size.height)
                    bottomImage.draw(in: areaSize)
                    
                    topImage.draw(in: areaSize, blendMode: CGBlendMode.normal, alpha: 1.0)
                    
                    let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
                    UIGraphicsEndImageContext()
                    return newImage
                }
            } catch {
            }
        }
        return UIImage(named: "ic_cluster")!
    }
}
