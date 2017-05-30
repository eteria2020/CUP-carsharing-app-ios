//
//  CarPopupView.swift
//  Sharengo
//
//  Created by Dedecube on 27/05/17.
//  Copyright © 2017 Dedecube. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Boomerang
import Action
import CoreLocation
import DeviceKit

class CarPopupView: UIView {
    @IBOutlet fileprivate weak var btn_open: UIButton!
    @IBOutlet fileprivate weak var btn_book: UIButton!
    @IBOutlet fileprivate weak var view_type: UIView!
    @IBOutlet fileprivate weak var lbl_type: UILabel!
    @IBOutlet fileprivate weak var view_separator: UIView!
    @IBOutlet fileprivate weak var lbl_plate: UILabel!
    @IBOutlet fileprivate weak var lbl_capacity: UILabel!
    @IBOutlet fileprivate weak var icn_address: UIImageView!
    @IBOutlet fileprivate weak var lbl_address: UILabel!
    @IBOutlet fileprivate weak var icn_distance: UIImageView!
    @IBOutlet fileprivate weak var lbl_distance: UILabel!
    @IBOutlet fileprivate weak var lbl_walkingDistance: UILabel!
    @IBOutlet fileprivate weak var icn_walkingDistance: UIImageView!
    fileprivate var view: UIView!
    
    var viewModel: CarPopupViewModel?
    
    // MARK: - ViewModel methods
    
    func bind(to viewModel: ViewModelType?) {
        guard let viewModel = viewModel as? CarPopupViewModel else {
            return
        }
        self.viewModel = viewModel
        viewModel.type.asObservable()
            .subscribe(onNext: {[weak self] (type) in
                DispatchQueue.main.async {
                    if type.isEmpty {
                        self?.view_type.constraint(withIdentifier: "typeHeight", searchInSubviews: false)?.constant = 0
                        self?.view_separator.isHidden = true
                    } else {
                        self?.view_type.constraint(withIdentifier: "typeHeight", searchInSubviews: false)?.constant = 40
                        self?.view_separator.isHidden = false
                        self?.lbl_type.styledText = type
                    }
                }
        }).addDisposableTo(disposeBag)
        self.btn_open.rx.bind(to: viewModel.selection, input: .open)
        self.btn_book.rx.bind(to: viewModel.selection, input: .book)
    }
    
    // MARK: - View methods
    
    func updateWithCar(car: Car) {
        self.viewModel?.updateWithCar(car: car)
        self.lbl_plate.styledText = String(format: "lbl_carPopupPlate".localized(), car.plate ?? "")
        self.lbl_capacity.styledText = String(format: "lbl_carPopupCapacity".localized(), car.capacity ?? "")
        if let distance = car.distance {
            self.lbl_distance.styledText = String(format: "lbl_carPopupDistance".localized(), Int(distance.rounded()))
            let minutes: Float = Float(distance.rounded()/100.0)
            self.lbl_walkingDistance.styledText = String(format: "lbl_carPopupWalkingDistance".localized(), Int(minutes.rounded()))
            self.icn_walkingDistance.isHidden = false
            self.lbl_walkingDistance.isHidden = false
            self.icn_distance.isHidden = false
            self.lbl_distance.isHidden = false
        } else {
            self.icn_walkingDistance.isHidden = true
            self.lbl_walkingDistance.isHidden = true
            self.icn_distance.isHidden = true
            self.lbl_distance.isHidden = true
        }
        if let address = car.address.value {
            self.lbl_address.styledText = address
        } else {
            self.lbl_address.bonMotStyleName = "carPopupAddressPlaceholder"
            self.lbl_address.styledText = "lbl_carPopupAddressPlaceholder".localized()
            car.getAddress()
            car.address.asObservable()
                .subscribe(onNext: {[weak self] (address) in
                    DispatchQueue.main.async {
                        if address != nil {
                            self?.lbl_address.bonMotStyleName = "carPopupAddress"
                            self?.lbl_address.styledText = address!
                        }
                    }
            }).addDisposableTo(disposeBag)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        xibSetup()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        xibSetup()
    }
    
    fileprivate func xibSetup() {
        view = loadViewFromNib()
        view.frame = bounds
        view.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]
        addSubview(view)
        self.layoutIfNeeded()
        self.view.backgroundColor = Color.carPopupBackground.value
        self.btn_open.style(.roundedButton, title: "btn_open".localized())
        self.btn_book.style(.roundedButton, title: "btn_book".localized())
        self.view_separator.constraint(withIdentifier: "separatorHeight", searchInSubviews: false)?.constant = 1
        switch Device().diagonal {
        case 3.5:
            self.constraint(withIdentifier: "buttonsHeight", searchInSubviews: true)?.constant = 35
        case 4:
            self.constraint(withIdentifier: "buttonsHeight", searchInSubviews: true)?.constant = 38
        default:
            self.constraint(withIdentifier: "buttonsHeight", searchInSubviews: true)?.constant = 40
        }
    }
    
    fileprivate func loadViewFromNib() -> UIView {
        let nib = ViewXib.carPopup.getNib()
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        return view
    }
}
