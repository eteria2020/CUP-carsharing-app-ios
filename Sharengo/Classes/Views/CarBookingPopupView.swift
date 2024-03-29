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

import Action
import CoreLocation
import DeviceKit

class CarBookingPopupView: UIView
{
    @IBOutlet fileprivate weak var btn_open: UIButton!
    @IBOutlet fileprivate weak var btn_openCentered: UIButton!
    @IBOutlet fileprivate weak var btn_delete: UIButton!
    @IBOutlet fileprivate weak var lbl_pin: UILabel!
    @IBOutlet fileprivate weak var lbl_info: UILabel!
    @IBOutlet fileprivate weak var lbl_time: UILabel!
    @IBOutlet fileprivate weak var icn_time: UIImageView!
    @IBOutlet fileprivate weak var view_time: UIView!
    @IBOutlet fileprivate weak var view_pin: UIView!
    @IBOutlet fileprivate weak var view_info: UIView!
    fileprivate var view: UIView!
    fileprivate var firstLoaded: Bool = false
    
    var viewModel: CarBookingPopupViewModel?
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
    }
    
    required init(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)!
    }
    
    // MARK: - ViewModel methods
    
    func bind(to viewModel: ViewModelType?)
    {
        guard let viewModel = viewModel as? CarBookingPopupViewModel else
        {
            return
        }
        
        self.viewModel = viewModel
        self.viewModel?.carBookingPopupView = self
        
        xibSetup()
        
        self.btn_open.rx.bind(to: viewModel.selection, input: .open)
        self.btn_openCentered.rx.bind(to: viewModel.selection, input: .close)
//        self.btn_openCentered.rx.bind(to: viewModel.selection, input: .open)
        self.btn_delete.rx.bind(to: viewModel.selection, input: .delete)
    }
    
    // MARK: - View methods
    
    func updateWithCarBooking(carBooking: CarBooking)
    {
        guard let viewModel = viewModel else { return }
        
        viewModel.carTrip = nil
        viewModel.updateWithCarBooking(carBooking: carBooking)
        
        self.updateData()
    }
    
    func updateWithCarTrip(carTrip: CarTrip)
    {
        guard let viewModel = viewModel else { return }
        
        viewModel.carBooking = nil
        viewModel.updateWithCarTrip(carTrip: carTrip)
        
        self.updateData()
    }
    
    fileprivate func updateData()
    {
        guard let viewModel = viewModel else { return }
        
        if !self.firstLoaded
        {
            self.icn_time.isHidden = true
        }
        
        self.lbl_pin.styledText = viewModel.pin
        self.btn_openCentered.isHidden = false
        self.btn_open.isHidden = false
        self.btn_delete.isHidden = false
        self.updateButtons()
        
        viewModel.info.asObservable().subscribe(onNext: { [weak self] info in
            DispatchQueue.main.async {
                self?.lbl_info.styledText = info
            }
        }).disposed(by: disposeBag)
        
        viewModel.isCarClosing.asObservable().subscribe { [weak self] isCarClosing in
            DispatchQueue.main.async {
                self?.updateButtons()
            }
            }.disposed(by: disposeBag)
    
        viewModel.time.asObservable().subscribe(onNext: { [weak self] time in
            DispatchQueue.main.async {
                self?.firstLoaded = true
                
                if time != ""
                {
                    self?.icn_time.isHidden = false
                    self?.lbl_time.styledText = time
                    
                    let screenWidth = UIScreen.main.bounds.size.width
                    let constraint = self?.view_time.constraint(withIdentifier: "widthIcnTime", searchInSubviews: true)
                    
                    if self?.viewModel?.carBooking != nil
                    {
                        self?.icn_time.image = UIImage(named: "ic_time_1")
                        constraint?.constant = screenWidth * 0.4
                    }
                    else if self?.viewModel?.carTrip != nil
                    {
                        self?.icn_time.image = UIImage(named: "ic_time_2")
                        constraint?.constant = screenWidth * 0.45
                    }
                }
                else
                {
                    self?.lbl_time.styledText = ""
                    self?.icn_time.isHidden = true
                }
            }
        }).disposed(by: disposeBag)
    }
    
    func updateButtons()
    {
        guard let viewModel = viewModel else { return }

        btn_delete.isEnabled = true
        btn_openCentered.isEnabled = true

        if viewModel.hideButtons
        {
            if viewModel.carTrip != nil
            {
                if viewModel.carTrip?.car.value?.parking == true
                {
                    if let version = viewModel.carTrip?.car.value?.versionOBC{
                        var versionObc = version
                        versionObc =  versionObc.stringByReplacingFirstOccurrenceOfString(target: ".", withString: ",")
                        versionObc = versionObc.substring(to: versionObc.firstIndex(of: ".")!)
                        versionObc = versionObc.stringByReplacingFirstOccurrenceOfString(target: ",", withString: "")
                        
                        if Int(versionObc)! >= 109{
                            btn_openCentered.isHidden = true
                            btn_open.isHidden = false
                            btn_delete.isHidden = false
                            btn_delete.style(.roundedButton(Color.alertButtonsRedBackground.value), title: "btn_close".localized())
                            btn_delete.rx.bind(to: viewModel.selection, input: .close)
                            btn_delete.isEnabled = !viewModel.isCarClosing.value
                        }
                        else{
                            btn_openCentered.isHidden = false
                            btn_open.isHidden = true
                            btn_delete.isHidden = true
                            btn_openCentered.style(.roundedButton(Color.alertButtonsGreenBackground.value), title: "btn_open".localized())
                            btn_openCentered.rx.bind(to: viewModel.selection, input: .open)
                          
                            
                        }
                        
                    }else{
                    btn_openCentered.isHidden = true
                    btn_open.isHidden = false
                    btn_delete.isHidden = false
                    btn_delete.style(.roundedButton(Color.alertButtonsRedBackground.value), title: "btn_close".localized())
                    btn_delete.rx.bind(to: viewModel.selection, input: .close)
                    btn_delete.isEnabled = !viewModel.isCarClosing.value

                  
                    }
                     return
                }
               
               
            }


            if CoreController.shared.currentCarTrip != nil
            {
                //case: open Trips
                btn_openCentered.style(.roundedButton(Color.alertButtonsRedBackground.value), title: "btn_close".localized())
                btn_openCentered.rx.bind(to: viewModel.selection, input: .close)
                
                if let version = viewModel.carTrip?.car.value?.versionOBC{
                    var versionObc = version
                    versionObc =  versionObc.stringByReplacingFirstOccurrenceOfString(target: ".", withString: ",")
                    versionObc = versionObc.substring(to: versionObc.firstIndex(of: ".")!)
                    versionObc = versionObc.stringByReplacingFirstOccurrenceOfString(target: ",", withString: "")

                    if Int(versionObc)! >= 109{
                        btn_openCentered.isHidden = false
                        btn_openCentered.isEnabled = !viewModel.isCarClosing.value
                    }
                    else{
                        btn_openCentered.isHidden = true

                    }
                    
                }else{
                btn_openCentered.isHidden = false
                btn_openCentered.isEnabled = !viewModel.isCarClosing.value
                    
                }
                btn_open.isHidden = true
                btn_delete.isHidden = true
            }
            else
            {
                
                btn_openCentered.isHidden = true
                btn_open.isHidden = true
                btn_delete.isHidden = true
                
            }
        }
        else
        {
            //case: Reservation
            btn_openCentered.isHidden = true
            btn_open.isHidden = false
            btn_open.style(.roundedButton(Color.alertButtonsGreenBackground.value), title: "btn_open".localized())
            btn_delete.isHidden = false
            btn_delete.style(.roundedButton(Color.alertButtonsRedBackground.value), title: "btn_delete".localized())
            btn_delete.rx.bind(to: viewModel.selection, input: .delete)
        }
    }
    
//    func updateButtons() {
//        guard let viewModel = viewModel else {
//            return
//        }
//        if viewModel.hideButtons {
//            if viewModel.carTrip != nil {
//                if viewModel.carTrip?.car.value?.parking == true {
//                    self.btn_openCentered.isHidden = false
//                    self.btn_open.isHidden = true
//                    self.btn_delete.isHidden = true
//                    return
//                }
//            }
//            self.btn_openCentered.isHidden = true
//            self.btn_open.isHidden = true
//            self.btn_delete.isHidden = true
//        } else {
//            self.btn_openCentered.isHidden = true
//            self.btn_open.isHidden = false
//            self.btn_delete.isHidden = false
//        }
//    }

    
    fileprivate func xibSetup()
    {
        view = loadViewFromNib()
        view.frame = bounds
        view.autoresizingMask = [UIView.AutoresizingMask.flexibleWidth, UIView.AutoresizingMask.flexibleHeight]
        addSubview(view)
        
        self.layoutIfNeeded()
        
        self.view.backgroundColor = Color.carBookingPopupBackground.value
//        scommentare in caso di rimozione bottone chiudi corsa
        self.btn_openCentered.style(.roundedButton(Color.alertButtonsRedBackground.value), title: "btn_close".localized())
//        self.btn_openCentered.style(.roundedButton(Color.alertButtonsNegativeBackground.value), title: "btn_open".localized())
        self.btn_open.style(.roundedButton(Color.alertButtonsGreenBackground.value), title: "btn_open".localized())
        self.btn_delete.style(.roundedButton(Color.alertButtonsRedBackground.value), title: "btn_delete".localized())
        self.lbl_info.styledText = ""
    }
    
    fileprivate func loadViewFromNib() -> UIView
    {
        let nib = ViewXib.carBookingPopup.getNib()
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        return view
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool
    {
        if self.view.point(inside: convert(point, to: self.view), with: event)
        {
            if self.viewModel?.time.value != "" && view_time.point(inside: convert(point, to: view_time), with: event)
            {
                return true
            }
            else if view_pin.point(inside: convert(point, to: view_pin), with: event)
            {
                return true
            }
            else if view_info.point(inside: convert(point, to: view_info), with: event)
            {
                return true
            }
            else if (self.viewModel?.hideButtons == false || self.viewModel?.carTrip?.car.value?.parking == true) && (btn_open.point(inside: convert(point, to: btn_open), with: event) || btn_delete.point(inside: convert(point, to: btn_delete), with: event))
            {
                return true
            }
            else if (self.viewModel?.hideButtons == false || btn_openCentered.point(inside: convert(point, to: btn_openCentered), with: event))
            {
                return true
            }
        }
        
        return false
    }
}

extension String
{
    func stringByReplacingFirstOccurrenceOfString(
        target: String, withString replaceString: String) -> String
    {
        if let range = self.range(of: target) {
            return self.replacingCharacters(in: range, with: replaceString)
        }
        return self
    }
}
