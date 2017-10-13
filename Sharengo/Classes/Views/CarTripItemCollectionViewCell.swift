//
//  CarTripItemCollectionViewCell.swift
//  Sharengo
//
//  Created by Dedecube on 30/06/17.
//  Copyright © 2017 Dedecube. All rights reserved.
//

import UIKit
import Boomerang
import RxSwift
import Action
import RxCocoa
import DeviceKit
import KeychainSwift

/**
 The CarTripItemCollectionViewCell shows data of singular car trip in a cell
 */
public class CarTripItemCollectionViewCell: UICollectionViewCell, ViewModelBindable {
    @IBOutlet fileprivate weak var img_icon: UIImageView!
    @IBOutlet fileprivate weak var img_collapsed: UIImageView!
    @IBOutlet fileprivate weak var view_topBorder: UIView!
    @IBOutlet fileprivate weak var lbl_title: UILabel!
    @IBOutlet fileprivate weak var lbl_subtitle: UILabel!
    @IBOutlet fileprivate weak var view_bottomBorder: UIView!
    @IBOutlet fileprivate weak var lbl_description: UILabel!
    /// ViewModel variable used to represents the data
    public var viewModel:ItemViewModelType?
    
    // MARK: - ViewModel methods
    
    public func bind(to viewModel: ViewModelType?) {
        guard let viewModel = viewModel as? CarTripItemViewModel else {
            return
        }
        self.layoutIfNeeded()
        self.viewModel = viewModel
    }
    
    /**
     This method updates car trip with selected id
     - Parameter idSelected: id of selected car trip
     */
    public func updateWithPlateSelected(idSelected: Int) {
        var title: String?
        var subtitle: String?
        
        guard let viewModel = viewModel else {
            return
        }
        let model = viewModel.model as! CarTrip
        let selected = (model.id ?? -1) == idSelected
        
        if model.id != nil
        {
            title = String(format: "lbl_carTripsItemTitle".localized(), "\(model.id!)")
        }
        else
        {
            title = String(format: "lbl_carTripsItemTitle".localized(), "")
        }
        
        if model.costComputed == true && model.totalCost != nil {
            let value = (Float(model.totalCost!)/100)
            let valueString = "\(value)".replacingOccurrences(of: ".", with: ",").replacingOccurrences(of: ",00", with: "")
            if valueString == "0" {
                subtitle = String(format: "lbl_carTripsItemSubtitle".localized(), model.endTime)
            } else {
                subtitle = String(format: "lbl_carTripsItemSubtitleTotalCost".localized(), model.endTime, Float(model.totalCost!)/100).replacingOccurrences(of: ".", with: ",").replacingOccurrences(of: ",00", with: "")
            }
        } else {
            subtitle = String(format: "lbl_carTripsItemSubtitle".localized(), model.endTime)
        }
        
        self.lbl_title.styledText = title
        self.lbl_subtitle.styledText = subtitle
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "lbl_carTripsDateFormatter".localized()
        dateFormatter.locale = Locale.current
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "lbl_carTripsTimeFormatter".localized()
        timeFormatter.locale = Locale.current
        var startDateText = ""
        var startTimeText = ""
        
        if let startDate = model.timeStart
        {
            startDateText = dateFormatter.string(from: startDate)
            startTimeText = timeFormatter.string(from: startDate)
        }
        
        if !selected
        {
            self.lbl_description.bonMotStyleName = "carTripsItemDescription"
            self.lbl_description.styledText = String(format: "lbl_carTripsItemDescription".localized(), startDateText.uppercased(), startTimeText.uppercased())
        }
        else
        {
            var endDateText = ""
            var endTimeText = ""
            if let endDate = model.timeEnd
            {
                endDateText = dateFormatter.string(from: endDate)
                endTimeText = timeFormatter.string(from: endDate)
            }
            
            var startAddress = "lbl_carTripsItemExtendedDescriptionPlaceholder".localized()
            var endAddress = "lbl_carTripsItemExtendedDescriptionPlaceholder".localized()
            let plate = model.carPlate ?? ""
            let discountRate = Int(KeychainSwift().get("UserDiscountRate") ?? "0") ?? 0
            let basicRate = 0.28 - (0.28 * Double(discountRate) / 100)
            
            self.lbl_description.styledText = String(format: "lbl_carTripsItemExtendedDescription".localized(), startDateText.uppercased(), startTimeText.uppercased(), startAddress, endDateText.uppercased(), endTimeText.uppercased(), endAddress, basicRate, plate).replacingOccurrences(of: ".", with: ",").replacingOccurrences(of: ",00", with: "")
            self.lbl_description.bonMotStyleName = "carTripsItemExtendedDescription"
            
            if let location = model.locationStart {
                let key = "address-\(location.coordinate.latitude)-\(location.coordinate.longitude)"
                if let address = UserDefaults.standard.object(forKey: key) as? String {
                    startAddress = "<startAddress>\(address)</startAddress>"
                    self.lbl_description.styledText = String(format: "lbl_carTripsItemExtendedDescription".localized(), startDateText.uppercased(), startTimeText.uppercased(), startAddress, endDateText.uppercased(), endTimeText.uppercased(), endAddress, basicRate, plate).replacingOccurrences(of: ".", with: ",").replacingOccurrences(of: ",00", with: "")
                } else {
                    let geocoder = CLGeocoder()
                    geocoder.reverseGeocodeLocation(location, completionHandler: { placemarks, error in
                        if let placemark = placemarks?.last {
                            if let thoroughfare = placemark.thoroughfare, let subthoroughfare = placemark.subThoroughfare, let locality = placemark.locality {
                                let address = "\(thoroughfare) \(subthoroughfare), \(locality)"
                                UserDefaults.standard.set(address, forKey: key)
                                startAddress = "<startAddress>\(address)</startAddress>"
                                self.lbl_description.styledText = String(format: "lbl_carTripsItemExtendedDescription".localized(), startDateText.uppercased(), startTimeText.uppercased(), startAddress, endDateText.uppercased(), endTimeText.uppercased(), endAddress, basicRate, plate).replacingOccurrences(of: ".", with: ",").replacingOccurrences(of: ",00", with: "")
                            } else if let thoroughfare = placemark.thoroughfare, let locality = placemark.locality {
                                let address = "\(thoroughfare), \(locality)"
                                UserDefaults.standard.set(address, forKey: key)
                                startAddress = "<startAddress>\(address)</startAddress>"
                                self.lbl_description.styledText = String(format: "lbl_carTripsItemExtendedDescription".localized(), startDateText.uppercased(), startTimeText.uppercased(), startAddress, endDateText.uppercased(), endTimeText.uppercased(), endAddress, basicRate, plate).replacingOccurrences(of: ".", with: ",").replacingOccurrences(of: ",00", with: "")
                            }
                        }
                    })
                }
            }
            if let location = model.locationEnd {
                let key = "address-\(location.coordinate.latitude)-\(location.coordinate.longitude)"
                if let address = UserDefaults.standard.object(forKey: key) as? String {
                    endAddress = "<endAddress>\(address)</endAddress>"
                    self.lbl_description.styledText = String(format: "lbl_carTripsItemExtendedDescription".localized(), startDateText.uppercased(), startTimeText.uppercased(), startAddress, endDateText.uppercased(), endTimeText.uppercased(), endAddress, basicRate, plate).replacingOccurrences(of: ".", with: ",").replacingOccurrences(of: ",00", with: "")
                } else {
                    let geocoder = CLGeocoder()
                    geocoder.reverseGeocodeLocation(location, completionHandler: { placemarks, error in
                        if let placemark = placemarks?.last {
                            if let thoroughfare = placemark.thoroughfare, let subthoroughfare = placemark.subThoroughfare, let locality = placemark.locality {
                                let address = "\(thoroughfare) \(subthoroughfare), \(locality)"
                                UserDefaults.standard.set(address, forKey: key)
                                endAddress = "<endAddress>\(address)</endAddress>"
                                self.lbl_description.styledText = String(format: "lbl_carTripsItemExtendedDescription".localized(), startDateText.uppercased(), startTimeText.uppercased(), startAddress, endDateText.uppercased(), endTimeText.uppercased(), endAddress, basicRate, plate).replacingOccurrences(of: ".", with: ",").replacingOccurrences(of: ",00", with: "")
                            } else if let thoroughfare = placemark.thoroughfare, let locality = placemark.locality {
                                let address = "\(thoroughfare), \(locality)"
                                UserDefaults.standard.set(address, forKey: key)
                                endAddress = "<endAddress>\(address)</endAddress>"
                                self.lbl_description.styledText = String(format: "lbl_carTripsItemExtendedDescription".localized(), startDateText.uppercased(), startTimeText.uppercased(), startAddress, endDateText.uppercased(), endTimeText.uppercased(), endAddress, basicRate, plate).replacingOccurrences(of: ".", with: ",").replacingOccurrences(of: ",00", with: "")
                            }
                        }
                    })
                }
            }
        }
        
        switch Device().diagonal {
        case 3.5:
            self.constraint(withIdentifier: "topImgIcon", searchInSubviews: true)?.constant = -3
            self.constraint(withIdentifier: "bottomLblTitle", searchInSubviews: true)?.constant = 1
            self.constraint(withIdentifier: "topLblDescription", searchInSubviews: true)?.constant = 1
            //            if !viewModel.selected {
            if !selected {
                self.constraint(withIdentifier: "yLblSubtitle", searchInSubviews: true)?.constant = 20
            } else {
                self.constraint(withIdentifier: "yLblSubtitle", searchInSubviews: true)?.constant = -29
            }
        case 4:
            self.constraint(withIdentifier: "bottomLblTitle", searchInSubviews: true)?.constant = 5
            self.constraint(withIdentifier: "topLblDescription", searchInSubviews: true)?.constant = 5
            //            if !viewModel.selected {
            if !selected {
                self.constraint(withIdentifier: "yLblSubtitle", searchInSubviews: true)?.constant = 20
            } else {
                self.constraint(withIdentifier: "yLblSubtitle", searchInSubviews: true)?.constant = -34
            }
        case 4.7, 5.8:
            self.constraint(withIdentifier: "topImgIcon", searchInSubviews: true)?.constant = 5
            self.constraint(withIdentifier: "bottomImgCollapsed", searchInSubviews: true)?.constant = 5
            //            if !viewModel.selected {
            if !selected {
                self.constraint(withIdentifier: "yLblSubtitle", searchInSubviews: true)?.constant = 20
            } else {
                self.constraint(withIdentifier: "yLblSubtitle", searchInSubviews: true)?.constant = -44
            }
        //case 5.5:
        default:
            self.constraint(withIdentifier: "topImgIcon", searchInSubviews: true)?.constant = 10
            self.constraint(withIdentifier: "bottomImgCollapsed", searchInSubviews: true)?.constant = 10
            //            if !viewModel.selected {
            if !selected {
                self.constraint(withIdentifier: "yLblSubtitle", searchInSubviews: true)?.constant = 20
            } else {
                self.constraint(withIdentifier: "yLblSubtitle", searchInSubviews: true)?.constant = -52
            }
        //default:
        //    break
        }
    }
}
