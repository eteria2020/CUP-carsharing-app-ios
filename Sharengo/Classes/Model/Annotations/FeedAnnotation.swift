//
//  FeedAnnotation.swift
//
//  Created by Dedecube on 23/05/17.
//  Copyright © 2017 Dedecube. All rights reserved.
//

import UIKit
import MapKit

class FeedAnnotation: FBAnnotation {
    var feed:Feed?
    lazy var image: UIImage = self.getImage()
    
    // MARK: - Lazy methods
    
    func getImage() -> UIImage {
        if let icon = self.feed?.marker,
            let url = URL(string: icon)
        {
            do {
                let data = try Data(contentsOf: url)
                if let image = UIImage(data: data) {
                    // TODO: misura corretta per big
                    // let size = CGSize(width: 46, height: 55)
                    let size = CGSize(width:38, height: 46)
                    UIGraphicsBeginImageContext(size)
                    
                    let areaSize = CGRect(x: 0, y: 0, width: size.width, height: size.height)
                    image.draw(in: areaSize)
                    
                    let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
                    UIGraphicsEndImageContext()
                    return newImage
                }
            } catch {
            }
        }
        // TODO: misura corretta per big
        // let size = CGSize(width: 46, height: 55)
        let size = CGSize(width:38, height: 46)
        UIGraphicsBeginImageContext(size)
        
        let areaSize = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        UIImage(named: "ic_puntatore-generico")!.draw(in: areaSize)
        
        let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
}
