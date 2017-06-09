//
//  NotificationsController.swift
//
//  Created by Dedecube on 09/06/17.
//  Copyright © 2017 Dedecube. All rights reserved.
//

import Foundation
import BRYXBanner

class NotificationsController
{
    class func showNotification(title: String, description: String) {
        let banner = Banner(title: title, subtitle: description, image: UIImage(named: ""), backgroundColor: UIColor.white)
        banner.springiness = BannerSpringiness.slight
        banner.position = BannerPosition.top
        banner.textColor = .black
        banner.didTapBlock = {
            print("Banner was tapped")
        }
        banner.show(duration: 3.0)
    }
}
