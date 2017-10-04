//
//  NotificationsController.swift
//
//  Created by Dedecube on 09/06/17.
//  Copyright © 2017 Dedecube. All rights reserved.
//

import Foundation

/**
 NotificationsController class is a controller that manage notifications task as show a single notification.
 */
public class NotificationsController
{
    /**
     This method show notification to user.
     - Parameter title: notification's title
     - Parameter description: description's title
     - Parameter carTrip: carTrip object used with tap to show car booking completed viewcontroller
     - Parameter source: viewController where will method show notification
     */
    public class func showNotification(title: String, description: String, carTrip: CarTrip?, source: UIViewController) {
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
