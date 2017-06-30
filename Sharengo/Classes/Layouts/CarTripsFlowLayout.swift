//
//  CarTripsFlowLayout.swift
//  Sharengo
//
//  Created by Dedecube on 30/06/17.
//  Copyright © 2017 Dedecube. All rights reserved.
//

import UIKit

class CarTripsCollectionViewFlowLayout: UICollectionViewFlowLayout
{
    var expand = false
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if self.expand {
            return CGSize(width: 120, height: 300)
        } else {
            return CGSize(width: 120, height: 120.0)
        }
    }

}
