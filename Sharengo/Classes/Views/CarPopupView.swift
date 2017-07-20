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
import BonMot

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
    @IBOutlet fileprivate weak var view_feed: UIView!
    @IBOutlet fileprivate weak var view_containerBackgroundImage: UIView!
    @IBOutlet fileprivate weak var img_background: UIImageView!
    @IBOutlet fileprivate weak var view_overlayBackgroundImage: UIView!
    @IBOutlet fileprivate weak var view_containerClaim: UIView!
    @IBOutlet fileprivate weak var lbl_claim: UILabel!
    @IBOutlet fileprivate weak var img_claim: UIImageView!
    @IBOutlet fileprivate weak var view_bottomContainer: UIView!
    @IBOutlet fileprivate weak var lbl_bottom: UILabel!
    @IBOutlet fileprivate weak var img_favorite: UIImageView!
    @IBOutlet fileprivate weak var img_icon: UIImageView!
    @IBOutlet fileprivate weak var view_icon: UIView!
    @IBOutlet fileprivate weak var lbl_category: UILabel!
    @IBOutlet fileprivate weak var btn_detail: UIButton!
    @IBOutlet fileprivate weak var btn_car: UIButton!
    fileprivate var view: UIView!
    
    var viewModel: CarPopupViewModel?
    
    // MARK: - ViewModel methods
    
    func bind(to viewModel: ViewModelType?) {
        guard let viewModel = viewModel as? CarPopupViewModel else {
            return
        }
        self.viewModel = viewModel
        viewModel.carType.asObservable()
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
        viewModel.type.asObservable()
            .subscribe(onNext: {[weak self] (type) in
                DispatchQueue.main.async {
                    switch type {
                    case .car:
                        self?.view_feed.isHidden = true
                    case .feed:
                        self?.view_feed.isHidden = false
                    }
                }
            }).addDisposableTo(disposeBag)
        xibSetup()
        self.btn_open.rx.bind(to: viewModel.selection, input: .open)
        self.btn_book.rx.bind(to: viewModel.selection, input: .book)
        self.btn_detail.rx.bind(to: viewModel.selection, input: .detail)
        self.btn_car.rx.bind(to: viewModel.selection, input: .car)
    }
    
    // MARK: - View methods
    
    func updateWithCar(car: Car) {
        guard let viewModel = viewModel else {
            return
        }
        viewModel.updateWithCar(car: car)
        self.lbl_plate.styledText = viewModel.plate
        self.lbl_capacity.styledText = viewModel.capacity
        self.lbl_distance.styledText = viewModel.distance
        self.lbl_walkingDistance.styledText = viewModel.walkingDistance
        if viewModel.distance.isEmpty {
            self.icn_walkingDistance.isHidden = true
            self.lbl_walkingDistance.isHidden = true
            self.icn_distance.isHidden = true
            self.lbl_distance.isHidden = true
        } else {
            self.icn_walkingDistance.isHidden = false
            self.lbl_walkingDistance.isHidden = false
            self.icn_distance.isHidden = false
            self.lbl_distance.isHidden = false
        }
        self.lbl_address.bonMotStyleName = "carPopupAddressPlaceholder"
        self.lbl_address.styledText = "lbl_carPopupAddressPlaceholder".localized()
        viewModel.address.asObservable()
            .subscribe(onNext: {[weak self] (address) in
                DispatchQueue.main.async {
                    if address != nil {
                        self?.lbl_address.bonMotStyleName = "carPopupAddress"
                        self?.lbl_address.styledText = address
                    }
                }
        }).addDisposableTo(disposeBag)
    }
    
    func updateWithFeed(feed: Feed) {
        guard let viewModel = viewModel else {
            return
        }
        viewModel.updateWithFeed(feed: feed)
        
        if viewModel.claim != nil && viewModel.claim?.isEmpty == false
        {
            self.view_containerClaim.isHidden = false
            self.lbl_claim.styledText = viewModel.claim
            self.img_claim.image = self.img_claim.image?.tinted(viewModel.color ?? UIColor())
        }
        else
        {
            self.view_containerClaim.isHidden = true
        }
        
        if let icon = viewModel.icon,
            let url = URL(string: icon)
        {
            do {
                let data = try Data(contentsOf: url)
                if let image = UIImage(data: data) {
                    self.img_icon.image = image.tinted(Color.feedsItemIconBorderBackground.value)
                }
            } catch {
            }
        }
        
        if let image = viewModel.image,
            let url = URL(string: image)
        {
            do {
                let data = try Data(contentsOf: url)
                if let image = UIImage(data: data) {
                    self.img_background.image = image
                }
            } catch {
            }
        }
        
        self.view_overlayBackgroundImage.backgroundColor = (viewModel.color ?? UIColor()).withAlphaComponent(0.5)
        
        let titleStyle = StringStyle(.font(Font.feedsItemTitle.value), .color(viewModel.color ?? UIColor()), .alignment(.left))
       
        self.lbl_category.bonMotStyle = StringStyle(.font(Font.feedsItemDescription.value), .color(Color.feedsItemDescription.value), .alignment(.center),.xmlRules([.style("title", titleStyle)]))
        self.lbl_category.styledText = viewModel.category
        
        let dateStyle = StringStyle(.font(Font.feedsItemDate2.value), .color(Color.feedsItemDate.value), .alignment(.left))
        let subtitleStyle = StringStyle(.font(Font.feedsItemSubtitle2.value), .color(Color.feedsItemSubtitle.value), .alignment(.left))
        let descriptionStyle = StringStyle(.font(Font.feedsItemDescription2.value), .color(Color.feedsItemDescription.value), .alignment(.left))
        let advantageStyle = StringStyle(.font(Font.feedsItemAdvantage2.value), .color(viewModel.advantageColor ?? UIColor()), .alignment(.left))
        
        self.lbl_bottom.bonMotStyle = StringStyle(.font(Font.feedsItemDescription.value), .color(Color.feedsItemDescription.value), .alignment(.center),.xmlRules([.style("title", titleStyle), .style("date", dateStyle), .style("subtitle", subtitleStyle), .style("description", descriptionStyle), .style("advantage", advantageStyle)]))
        self.lbl_bottom.styledText = viewModel.bottomText
        
        self.view_icon.backgroundColor = viewModel.color
        self.view_icon.layer.cornerRadius = self.view_icon.frame.size.width/2
        self.view_icon.layer.masksToBounds = true
        self.view_icon.layer.borderWidth = 1
        self.view_icon.layer.borderColor = Color.feedsItemIconBorderBackground.value.cgColor
        
        if viewModel.favourited
        {
            self.img_favorite.alpha = 1.0
        }
        else
        {
            self.img_favorite.alpha = 0.0
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
        self.view.backgroundColor = Color.carPopupBackground.value
        self.view_feed.backgroundColor = Color.carPopupBackground.value
        self.view_bottomContainer.backgroundColor = Color.carPopupBackground.value
        self.btn_open.style(.roundedButton(Color.alertButtonsPositiveBackground.value), title: "btn_open".localized())
        self.btn_book.style(.roundedButton(Color.alertButtonsPositiveBackground.value), title: "btn_book".localized())
        self.btn_detail.style(.roundedButton(Color.alertButtonsPositiveBackground.value), title: "btn_detail".localized())
        self.btn_car.style(.roundedButton(Color.alertButtonsPositiveBackground.value), title: "btn_car".localized())
        self.view_separator.constraint(withIdentifier: "separatorHeight", searchInSubviews: false)?.constant = 1
        switch Device().diagonal {
        case 3.5:
            self.constraint(withIdentifier: "buttonsHeight", searchInSubviews: true)?.constant = 35
            self.constraint(withIdentifier: "buttonHeight1", searchInSubviews: true)?.constant = 28
            self.constraint(withIdentifier: "buttonHeight2", searchInSubviews: true)?.constant = 28
        case 4:
            self.constraint(withIdentifier: "buttonsHeight", searchInSubviews: true)?.constant = 38
            self.constraint(withIdentifier: "buttonHeight1", searchInSubviews: true)?.constant = 31
            self.constraint(withIdentifier: "buttonHeight2", searchInSubviews: true)?.constant = 31
        default:
            self.constraint(withIdentifier: "buttonsHeight", searchInSubviews: true)?.constant = 40
            self.constraint(withIdentifier: "buttonHeight1", searchInSubviews: true)?.constant = 33
            self.constraint(withIdentifier: "buttonHeight2", searchInSubviews: true)?.constant = 33
        }
    }
    
    fileprivate func loadViewFromNib() -> UIView {
        let nib = ViewXib.carPopup.getNib()
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        return view
    }
}
