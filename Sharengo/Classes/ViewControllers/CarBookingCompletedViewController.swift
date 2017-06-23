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
import DeviceKit
import SideMenu

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
        self.btn_carRides.rx.bind(to: viewModel.selection, input: .openCarRides)
        viewModel.selection.elements.subscribe(onNext:{[weak self] output in
            if (self == nil) { return }
            switch output {
            case .openCarRides:
                print("Open car rides")
                break
            default: break
            }
        }).addDisposableTo(self.disposeBag)
        self.lbl_thanks.styledText = String(format: "lbl_carBookingCompletedCo2".localized(), viewModel.co2)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.layoutIfNeeded()
        self.view.backgroundColor = Color.carBookingCompletedBackground.value
        self.lbl_warning.styledText = "lbl_carBookingCompletedDescription".localized()
        switch Device().diagonal {
        case 3.5:
            self.btn_carRides.constraint(withIdentifier: "buttonHeight", searchInSubviews: false)?.constant = 33
            self.img_completed.constraint(withIdentifier: "imageHeight", searchInSubviews: false)?.constant = 130
        case 4:
            self.btn_carRides.constraint(withIdentifier: "buttonHeight", searchInSubviews: false)?.constant = 36
        default:
            self.btn_carRides.constraint(withIdentifier: "buttonHeight", searchInSubviews: false)?.constant = 38
        }
        self.btn_carRides.style(.roundedButton(Color.alertButtonsPositiveBackground.value), title: "btn_carRides".localized())
        // NavigationBar
        self.view_navigationBar.bind(to: ViewModelFactory.navigationBar(leftItemType: .home, rightItemType: .menu))
        self.view_navigationBar.viewModel?.selection.elements.subscribe(onNext:{[weak self] output in
            if (self == nil) { return }
            switch output {
            case .home:
                Router.exit(self!)
            case .menu:
                self?.present(SideMenuManager.menuRightNavigationController!, animated: true, completion: nil)
            default:
                break
            }
        }).addDisposableTo(self.disposeBag)
    }
}
