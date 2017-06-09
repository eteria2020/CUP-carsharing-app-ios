//
//  CarBookingCompletedViewController.swift
//  Sharengo
//
//  Created by Dedecube on 09/06/17.
//  Copyright © 2017 Dedecube. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Boomerang

class CarBookingCompletedViewController : UIViewController, ViewModelBindable {
    @IBOutlet fileprivate weak var view_navigationBar: NavigationBarView!
    @IBOutlet fileprivate weak var img_completed: UIImageView!
    @IBOutlet fileprivate weak var lbl_warning: UILabel!
    @IBOutlet fileprivate weak var lbl_thanks: UILabel!
    @IBOutlet fileprivate weak var btn_carRides: UIButton!

    var viewModel: CarBookingCompletedViewModel?

    func bind(to viewModel: ViewModelType?) {
        guard let viewModel = viewModel as? CarBookingCompletedViewModel else {
            return
        }
        self.viewModel = viewModel
    }

}
