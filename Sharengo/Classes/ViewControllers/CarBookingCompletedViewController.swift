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

import DeviceKit
import SideMenu

/**
 The CarBookingCompleted class is shown when user completed a car trip and he taps on notification
 */
public class CarBookingCompletedViewController : BaseViewController, ViewModelBindable {
    @IBOutlet fileprivate weak var view_navigationBar: NavigationBarView!
    @IBOutlet fileprivate weak var img_completed: UIImageView!
    @IBOutlet fileprivate weak var lbl_warning: UILabel!
    @IBOutlet fileprivate weak var lbl_thanks: UILabel!
    @IBOutlet fileprivate weak var btn_carRides: UIButton!
    /// ViewModel variable used to represents the data
    public var viewModel: CarBookingCompletedViewModel?

    // MARK: - ViewModel methods
    
    public func bind(to viewModel: ViewModelType?) {
        guard let viewModel = viewModel as? CarBookingCompletedViewModel else {
            return
        }
        self.viewModel = viewModel
        self.btn_carRides.rx.bind(to: viewModel.selection, input: .openCarRides)
        viewModel.selection.elements.subscribe(onNext:{[weak self] output in
            if (self == nil) { return }
            switch output {
            case .openCarRides:
                let destination: CarTripsViewController = (Storyboard.main.scene(.carTrips))
                destination.bind(to: CarTripsViewModel(), afterLoad: true)
                CoreController.shared.currentViewController?.navigationController?.pushViewController(destination, animated: false)
            default: break
            }
        }).addDisposableTo(self.disposeBag)
        self.lbl_thanks.styledText = String(format: "lbl_carBookingCompletedCo2".localized(), viewModel.co2)
    }

    // MARK: - Init methods
    
    override public func viewDidLoad() {
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
