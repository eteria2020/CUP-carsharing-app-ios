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
    @IBOutlet fileprivate weak var view_time: UIView!
    @IBOutlet fileprivate weak var view_pin: UIView!
    @IBOutlet fileprivate weak var view_info: UIView!
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
        viewModel.carTrip = nil
        viewModel.updateWithCarBooking(carBooking: carBooking)
        self.updateData()
    }
    
    func updateWithCarTrip(carTrip: CarTrip) {
        guard let viewModel = viewModel else {
            return
        }
        viewModel.carBooking = nil
        viewModel.updateWithCarTrip(carTrip: carTrip)
        self.updateData()
    }
    
    fileprivate func updateData() {
        guard let viewModel = viewModel else {
            return
        }
        self.lbl_pin.styledText = viewModel.pin
        self.btn_open.isHidden = false
        self.btn_delete.isHidden = false
        if viewModel.hideButtons {
            self.btn_open.isHidden = true
            self.btn_delete.isHidden = true
        }
        viewModel.info.asObservable()
            .subscribe(onNext: {[weak self] (info) in
                DispatchQueue.main.async {
                    self?.lbl_info.styledText = info
                }
            }).addDisposableTo(disposeBag)
        viewModel.time.asObservable()
            .subscribe(onNext: {[weak self] (time) in
                DispatchQueue.main.async {
                    if time != "" {
                        self?.icn_time.isHidden = false
                        self?.lbl_time.styledText = time
                        if self?.viewModel?.carBooking != nil {
                            self?.icn_time.image = UIImage(named: "ic_time_1")
                            self?.view_time.constraint(withIdentifier: "widthIcnTime", searchInSubviews: true)?.constant = UIScreen.main.bounds.size.width*0.4
                        } else if self?.viewModel?.carTrip != nil {
                            self?.icn_time.image = UIImage(named: "ic_time_2")
                            self?.view_time.constraint(withIdentifier: "widthIcnTime", searchInSubviews: true)?.constant = UIScreen.main.bounds.size.width*0.45
                        }
                    } else {
                        self?.lbl_time.styledText = ""
                        self?.icn_time.isHidden = true
                    }
                }
            }).addDisposableTo(disposeBag)
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
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        if self.view.point(inside: convert(point, to: self.view), with: event) {
            if self.viewModel?.time.value != "" && view_time.point(inside: convert(point, to: view_time), with: event) {
                return true
            } else if view_pin.point(inside: convert(point, to: view_pin), with: event) {
                return true
            } else if view_info.point(inside: convert(point, to: view_info), with: event) {
                return true
            } else if self.viewModel?.hideButtons == false && (btn_open.point(inside: convert(point, to: btn_open), with: event) || btn_delete.point(inside: convert(point, to: btn_delete), with: event)) {
                return true
            }
        }
        return false
    }
}
