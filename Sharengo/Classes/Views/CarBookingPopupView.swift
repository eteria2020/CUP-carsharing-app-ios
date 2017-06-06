//
//  CarBookingPopupView.swift
//  Sharengo
//
//  Created by Dedecube on 06/06/17.
//  Copyright © 2017 Dedecube. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Boomerang
import Action
import CoreLocation
import DeviceKit

class CarBookingPopupView: UIView {
    @IBOutlet fileprivate weak var btn_open: UIButton!
    @IBOutlet fileprivate weak var btn_delete: UIButton!
    @IBOutlet fileprivate weak var lbl_pin: UILabel!
    @IBOutlet fileprivate weak var lbl_info: UILabel!
    @IBOutlet fileprivate weak var lbl_time: UILabel!
    @IBOutlet fileprivate weak var icn_time: UIImageView!
    fileprivate var view: UIView!
    
    var viewModel: CarBookingPopupViewModel?
    
    // MARK: - ViewModel methods
    
    func bind(to viewModel: ViewModelType?) {
        guard let viewModel = viewModel as? CarBookingPopupViewModel else {
            return
        }
        self.viewModel = viewModel
        xibSetup()
        self.btn_open.rx.bind(to: viewModel.selection, input: .open)
        self.btn_delete.rx.bind(to: viewModel.selection, input: .delete)
    }
    
    // MARK: - View methods
    
    func updateWithCarBooking(carBooking: CarBooking) {
        guard let viewModel = viewModel else {
            return
        }
        viewModel.updateWithCarBooking(carBooking: carBooking)
        self.lbl_pin.styledText = viewModel.pin
        self.lbl_info.styledText = viewModel.info
        self.lbl_time.styledText = viewModel.time
        self.btn_open.isHidden = false
        self.btn_delete.isHidden = false
        if viewModel.hideButtons {
            self.btn_open.isHidden = true
            self.btn_delete.isHidden = true
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    fileprivate func xibSetup() {
        view = loadViewFromNib()
        view.frame = bounds
        view.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]
        addSubview(view)
        self.layoutIfNeeded()
        self.view.backgroundColor = Color.carBookingPopupBackground.value
        self.btn_open.style(.roundedButton(Color.alertButtonsPositiveBackground.value), title: "btn_open".localized())
        self.btn_delete.style(.roundedButton(Color.alertButtonsNegativeBackground.value), title: "bnt_delete".localized())
    }
    
    fileprivate func loadViewFromNib() -> UIView {
        let nib = ViewXib.carBookingPopup.getNib()
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        return view
    }
}
