//
//  CityAnnotation.swift
//
//  Created by Dedecube on 05/06/17.
//  Copyright © 2017 Dedecube. All rights reserved.
//

import UIKit
import MapKit

enum City {
    case empty
    case milan
    case rome
    case firence
    case modena
    
    var image: UIImage {
        switch self {
        case .milan:
            return UIImage(named: "ic_cluster_milan") ?? UIImage()
        case .rome:
            return UIImage(named: "ic_cluster_rome") ?? UIImage()
        case .firence:
            return UIImage(named: "ic_cluster_firence") ?? UIImage()
        case .modena:
            return UIImage(named: "ic_cluster_modena") ?? UIImage()
        default:
            return UIImage(named: "ic_cluster") ?? UIImage()
        }
    }
}

class CityAnnotation: FBAnnotation {
    var city: City = .empty
    lazy var image: UIImage = self.getImage()
    
    // MARK: - Lazy methods
    
    func getImage() -> UIImage {
        return city.image
    }
}
