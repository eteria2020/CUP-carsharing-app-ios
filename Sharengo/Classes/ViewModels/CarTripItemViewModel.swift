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

final class CarTripItemViewModel : ItemViewModelType {
    var model:ItemViewModelType.Model
    var itemIdentifier:ListIdentifier = CollectionViewCell.carTrip
    var title: String?
    var subtitle: String?
    var description: Variable<String> = Variable("")
    var selected = false

    init(model: CarTrip) {
        self.model = model
        let selected = model.selected
        self.selected = model.selected

        if model.id != nil
        {
            self.title = String(format: "lbl_carTripsItemTitle".localized(), "\(model.id!)")
        }
        else
        {
            self.title = String(format: "lbl_carTripsItemTitle".localized(), "")
        }

        self.subtitle = String(format: "lbl_carTripsItemSubtitle".localized(), model.endTime)

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
            self.description.value = String(format: "lbl_carTripsItemDescription".localized(), startDateText.uppercased(), startTimeText.uppercased())
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
            let kmTraveled = "\((model.kmEnd ?? 0) - (model.kmStart ?? 0))"
            let plate = model.carPlate ?? ""
            
            self.description.value = String(format: "lbl_carTripsItemExtendedDescription".localized(), startDateText.uppercased(), startTimeText.uppercased(), startAddress, endDateText.uppercased(), endTimeText.uppercased(), endAddress, kmTraveled, plate)
            
            if let location = model.locationStart {
                let geocoder = CLGeocoder()
                geocoder.reverseGeocodeLocation(location, completionHandler: { placemarks, error in
                    if let placemark = placemarks?.last {
                        if let thoroughfare = placemark.thoroughfare, let subthoroughfare = placemark.subThoroughfare, let locality = placemark.locality {
                            let address = "\(thoroughfare) \(subthoroughfare), \(locality)"
                            startAddress = "<startAddress>\(address)</startAddress>"
                            self.description.value = String(format: "lbl_carTripsItemExtendedDescription".localized(), startDateText.uppercased(), startTimeText.uppercased(), startAddress, endDateText.uppercased(), endTimeText.uppercased(), endAddress, kmTraveled, plate)
                        } else if let thoroughfare = placemark.thoroughfare, let locality = placemark.locality {
                            let address = "\(thoroughfare), \(locality)"
                            startAddress = "<startAddress>\(address)</startAddress>"
                            self.description.value = String(format: "lbl_carTripsItemExtendedDescription".localized(), startDateText.uppercased(), startTimeText.uppercased(), startAddress, endDateText.uppercased(), endTimeText.uppercased(), endAddress, kmTraveled, plate)
                        }
                    }
                })
            }
            if let location = model.locationEnd {
                let geocoder = CLGeocoder()
                geocoder.reverseGeocodeLocation(location, completionHandler: { placemarks, error in
                    if let placemark = placemarks?.last {
                        if let thoroughfare = placemark.thoroughfare, let subthoroughfare = placemark.subThoroughfare, let locality = placemark.locality {
                            let address = "\(thoroughfare) \(subthoroughfare), \(locality)"
                            endAddress = "<endAddress>\(address)</endAddress>"
                            self.description.value = String(format: "lbl_carTripsItemExtendedDescription".localized(), startDateText.uppercased(), startTimeText.uppercased(), startAddress, endDateText.uppercased(), endTimeText.uppercased(), endAddress, kmTraveled, plate)
                        } else if let thoroughfare = placemark.thoroughfare, let locality = placemark.locality {
                            let address = "\(thoroughfare), \(locality)"
                            endAddress = "<endAddress>\(address)</endAddress>"
                            self.description.value = String(format: "lbl_carTripsItemExtendedDescription".localized(), startDateText.uppercased(), startTimeText.uppercased(), startAddress, endDateText.uppercased(), endTimeText.uppercased(), endAddress, kmTraveled, plate)
                        }
                    }
                })
            }
        }
    }
}
