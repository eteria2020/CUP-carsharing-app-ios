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

class CarPopupView: UIView {
    @IBOutlet weak var btn_open: UIButton!
    @IBOutlet weak var btn_book: UIButton!
    @IBOutlet weak var view_type: UIView!
    @IBOutlet weak var lbl_type: UILabel!
    @IBOutlet weak var lbl_plate: UILabel!
    @IBOutlet weak var lbl_capacity: UILabel!
    @IBOutlet weak var icn_address: UIImageView!
    @IBOutlet weak var lbl_address: UILabel!
    @IBOutlet weak var icn_distance: UIImageView!
    @IBOutlet weak var lbl_distance: UILabel!
    @IBOutlet weak var lbl_walkingDistance: UILabel!
    @IBOutlet weak var icn_walkingDistance: UIImageView!
    
    fileprivate var view: UIView!
    
    var viewModel: CarPopupViewModel?
    
    // MARK: - ViewModel methods
    
    func bind(to viewModel: ViewModelType?) {
        guard let viewModel = viewModel as? CarPopupViewModel else {
            return
        }
        self.viewModel = viewModel
        self.setupInterface()
    }
    
    // MARK: - View methods
    
    fileprivate func setupInterface() {
        guard let viewModel = viewModel else {
            return
        }
        viewModel.type.asObservable()
            .subscribe(onNext: {[weak self] (type) in
                DispatchQueue.main.async {
                    if type.isEmpty {
                        self?.view_type.constraint(withIdentifier: "typeHeight", searchInSubviews: false)?.constant = 0
                    } else {
                        self?.view_type.constraint(withIdentifier: "typeHeight", searchInSubviews: false)?.constant = 50
                        self?.lbl_type.text = type
                    }
                }
        }).addDisposableTo(disposeBag)
        self.layoutIfNeeded()
        self.view.backgroundColor = Color.carPopupBackground.value
        self.btn_open.style(.roundedButton, title: "btn_open".localized())
        self.btn_open.rx.bind(to: viewModel.selection, input: .open)
        self.btn_book.style(.roundedButton, title: "btn_book".localized())
        self.btn_book.rx.bind(to: viewModel.selection, input: .book)
    }
    
    func updateWithCar(car: Car) {
        self.viewModel?.updateWithCar(car: car)
        self.lbl_plate.styledText = String(format: "lbl_carPopupPlate".localized(), car.plate ?? "")
        self.lbl_capacity.styledText = String(format: "lbl_carPopupCapacity".localized(), car.capacity ?? "")
        if let distance = car.distance {
            self.lbl_distance.styledText = String(format: "lbl_carPopupDistance".localized(), Int(distance.rounded()))
            let minutes: Float = Float(distance.rounded()/100.0)
            self.lbl_walkingDistance.styledText = String(format: "lbl_carPopupWalkingDistance".localized(), Int(minutes.rounded()))
        } else {
            self.icn_walkingDistance.isHidden = true
            self.lbl_walkingDistance.isHidden = true
            self.icn_distance.isHidden = true
            self.lbl_distance.isHidden = true
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
    }
    
    fileprivate func loadViewFromNib() -> UIView {
        let nib = ViewXib.carPopup.getNib()
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        return view
    }
}
