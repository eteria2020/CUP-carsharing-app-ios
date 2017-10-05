//
//  CarTripItemViewModel.swift
//  Sharengo
//
//  Created by Dedecube on 30/06/17.
//  Copyright © 2017 Dedecube. All rights reserved.
//

import Foundation
import RxSwift
import Boomerang
import KeychainSwift

/**
 The Car Trip viewmodel provides data related to display content on car trip collection view cell
 */
public class CarTripItemViewModel : ItemViewModelType {
    public var model:ItemViewModelType.Model
    public var itemIdentifier:ListIdentifier = CollectionViewCell.carTrip
//    var title: String?
//    var subtitle: String?
//    var description: Variable<String> = Variable("")
//    var selected = false

    init(model: CarTrip) {
        self.model = model
//        let selected = model.selected
//        self.selected = model.selected
//
//        if model.id != nil
//        {
//            self.title = String(format: "lbl_carTripsItemTitle".localized(), "\(model.id!)")
//        }
//        else
//        {
//            self.title = String(format: "lbl_carTripsItemTitle".localized(), "")
//        }
//
//        if model.costComputed == true && model.totalCost != nil {
//            self.subtitle = String(format: "lbl_carTripsItemSubtitleTotalCost".localized(), model.endTime, Float(model.totalCost!)/100).replacingOccurrences(of: ".", with: ",").replacingOccurrences(of: ",00", with: "")
//        } else {
//            self.subtitle = String(format: "lbl_carTripsItemSubtitle".localized(), model.endTime)
//        }
//        
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "lbl_carTripsDateFormatter".localized()
//        dateFormatter.locale = Locale.current
//        let timeFormatter = DateFormatter()
//        timeFormatter.dateFormat = "lbl_carTripsTimeFormatter".localized()
//        timeFormatter.locale = Locale.current
//        var startDateText = ""
//        var startTimeText = ""
//
//        if let startDate = model.timeStart
//        {
//            startDateText = dateFormatter.string(from: startDate)
//            startTimeText = timeFormatter.string(from: startDate)
//        }
//
//        if !selected
//        {
//            self.description.value = String(format: "lbl_carTripsItemDescription".localized(), startDateText.uppercased(), startTimeText.uppercased())
//        }
//        else
//        {
//            var endDateText = ""
//            var endTimeText = ""
//            if let endDate = model.timeEnd
//            {
//                endDateText = dateFormatter.string(from: endDate)
//                endTimeText = timeFormatter.string(from: endDate)
//            }
//            
//            var startAddress = "lbl_carTripsItemExtendedDescriptionPlaceholder".localized()
//            var endAddress = "lbl_carTripsItemExtendedDescriptionPlaceholder".localized()
//            let plate = model.carPlate ?? ""
//            let discountRate = Int(KeychainSwift().get("UserDiscountRate") ?? "0") ?? 0
//            let basicRate = 0.28 - (0.28 * Double(discountRate) / 100)
//            
//            self.description.value = String(format: "lbl_carTripsItemExtendedDescription".localized(), startDateText.uppercased(), startTimeText.uppercased(), startAddress, endDateText.uppercased(), endTimeText.uppercased(), endAddress, basicRate, plate).replacingOccurrences(of: ".", with: ",").replacingOccurrences(of: ",00", with: "")
//            
//            if let location = model.locationStart {
//                let key = "address-\(location.coordinate.latitude)-\(location.coordinate.longitude)"
//                if let address = UserDefaults.standard.object(forKey: key) as? String {
//                    startAddress = "<startAddress>\(address)</startAddress>"
//                    self.description.value = String(format: "lbl_carTripsItemExtendedDescription".localized(), startDateText.uppercased(), startTimeText.uppercased(), startAddress, endDateText.uppercased(), endTimeText.uppercased(), endAddress, basicRate, plate).replacingOccurrences(of: ".", with: ",").replacingOccurrences(of: ",00", with: "")
//                } else {
//                    let geocoder = CLGeocoder()
//                    geocoder.reverseGeocodeLocation(location, completionHandler: { placemarks, error in
//                        if let placemark = placemarks?.last {
//                            if let thoroughfare = placemark.thoroughfare, let subthoroughfare = placemark.subThoroughfare, let locality = placemark.locality {
//                                let address = "\(thoroughfare) \(subthoroughfare), \(locality)"
//                                UserDefaults.standard.set(address, forKey: key)
//                                startAddress = "<startAddress>\(address)</startAddress>"
//                                self.description.value = String(format: "lbl_carTripsItemExtendedDescription".localized(), startDateText.uppercased(), startTimeText.uppercased(), startAddress, endDateText.uppercased(), endTimeText.uppercased(), endAddress, basicRate, plate).replacingOccurrences(of: ".", with: ",").replacingOccurrences(of: ",00", with: "")
//                            } else if let thoroughfare = placemark.thoroughfare, let locality = placemark.locality {
//                                let address = "\(thoroughfare), \(locality)"
//                                UserDefaults.standard.set(address, forKey: key)
//                                startAddress = "<startAddress>\(address)</startAddress>"
//                                self.description.value = String(format: "lbl_carTripsItemExtendedDescription".localized(), startDateText.uppercased(), startTimeText.uppercased(), startAddress, endDateText.uppercased(), endTimeText.uppercased(), endAddress, basicRate, plate).replacingOccurrences(of: ".", with: ",").replacingOccurrences(of: ",00", with: "")
//                            }
//                        }
//                    })
//                }
//            }
//            if let location = model.locationEnd {
//                let key = "address-\(location.coordinate.latitude)-\(location.coordinate.longitude)"
//                if let address = UserDefaults.standard.object(forKey: key) as? String {
//                    endAddress = "<endAddress>\(address)</endAddress>"
//                    self.description.value = String(format: "lbl_carTripsItemExtendedDescription".localized(), startDateText.uppercased(), startTimeText.uppercased(), startAddress, endDateText.uppercased(), endTimeText.uppercased(), endAddress, basicRate, plate).replacingOccurrences(of: ".", with: ",").replacingOccurrences(of: ",00", with: "")
//                } else {
//                    let geocoder = CLGeocoder()
//                    geocoder.reverseGeocodeLocation(location, completionHandler: { placemarks, error in
//                        if let placemark = placemarks?.last {
//                            if let thoroughfare = placemark.thoroughfare, let subthoroughfare = placemark.subThoroughfare, let locality = placemark.locality {
//                                let address = "\(thoroughfare) \(subthoroughfare), \(locality)"
//                                UserDefaults.standard.set(address, forKey: key)
//                                endAddress = "<endAddress>\(address)</endAddress>"
//                                self.description.value = String(format: "lbl_carTripsItemExtendedDescription".localized(), startDateText.uppercased(), startTimeText.uppercased(), startAddress, endDateText.uppercased(), endTimeText.uppercased(), endAddress, basicRate, plate).replacingOccurrences(of: ".", with: ",").replacingOccurrences(of: ",00", with: "")
//                            } else if let thoroughfare = placemark.thoroughfare, let locality = placemark.locality {
//                                let address = "\(thoroughfare), \(locality)"
//                                UserDefaults.standard.set(address, forKey: key)
//                                endAddress = "<endAddress>\(address)</endAddress>"
//                                self.description.value = String(format: "lbl_carTripsItemExtendedDescription".localized(), startDateText.uppercased(), startTimeText.uppercased(), startAddress, endDateText.uppercased(), endTimeText.uppercased(), endAddress, basicRate, plate).replacingOccurrences(of: ".", with: ",").replacingOccurrences(of: ",00", with: "")
//                            }
//                        }
//                    })
//                }
//            }
//        }
    }
}
