//
//  NotificationsController.swift
//
//  Created by Dedecube on 09/06/17.
//  Copyright © 2017 Dedecube. All rights reserved.
//

import Foundation

class NotificationsController
{
    class func showNotification(title: String, description: String, carTrip: CarTrip?, source: UIViewController) {
        let banner = Banner(title: title, subtitle: description, image: UIImage(named: "img_notification_car"), backgroundColor: Color.carBookingCompletedBannerBackground.value)
        banner.shouldTintImage = false
        banner.springiness = BannerSpringiness.slight
        banner.position = BannerPosition.top
        banner.textColor = Color.carBookingCompletedBannerLabel.value
        banner.titleLabel.font = Font.carBookingCompletedBannerLabelEmphasized.value
        banner.detailLabel.font = Font.carBookingCompletedBannerLabel.value
        banner.didTapBlock = {
            if carTrip != nil {
                let destination:CarBookingCompletedViewController = (Storyboard.main.scene(.carBookingCompleted))
                let viewModel = ViewModelFactory.carBookingCompleted(carTrip: carTrip!)
                destination.bind(to: viewModel, afterLoad: true)
                source.navigationController?.pushViewController(destination, animated: true)
            }
        }
        banner.show(duration: 3.0)
    }
}
