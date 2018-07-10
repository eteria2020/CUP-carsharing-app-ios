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

class CarTripItemCollectionViewCell: UICollectionViewCell, ViewModelBindable {
    @IBOutlet fileprivate weak var img_icon: UIImageView!
    @IBOutlet fileprivate weak var img_collapsed: UIImageView!
    @IBOutlet fileprivate weak var view_topBorder: UIView!
    @IBOutlet fileprivate weak var lbl_title: UILabel!
    @IBOutlet fileprivate weak var lbl_subtitle: UILabel!
    @IBOutlet fileprivate weak var view_bottomBorder: UIView!
    @IBOutlet fileprivate weak var lbl_description: UILabel!

    var viewModel:ItemViewModelType?
    
    // MARK: - ViewModel methods
    
    func bind(to viewModel: ViewModelType?) {
        guard let viewModel = viewModel as? CarTripItemViewModel else {
            return
        }
        self.layoutIfNeeded()
        self.viewModel = viewModel
        
        if !viewModel.selected
        {
            self.lbl_description.bonMotStyleName = "carTripsItemDescription"
            self.img_collapsed.image = UIImage(named: "ic_open_collapsed")
        }
        else
        {
            self.lbl_description.bonMotStyleName = "carTripsItemExtendedDescription"
            self.img_collapsed.image = UIImage(named: "ic_close_collapsed")
        }
        
        self.lbl_title.styledText = viewModel.title
        self.lbl_subtitle.styledText = viewModel.subtitle
        
        viewModel.description.asObservable()
            .subscribe(onNext: { [weak self] description in
                DispatchQueue.main.async { [weak self] in
                    if !viewModel.selected
                    {
                        self?.lbl_description.bonMotStyleName = "carTripsItemDescription"
                    }
                    else
                    {
                        self?.lbl_description.bonMotStyleName = "carTripsItemExtendedDescription"
                    }
                    self?.lbl_description.styledText = description
                }
            }).addDisposableTo(disposeBag)
        
        switch Device().diagonal {
        case 3.5:
            self.constraint(withIdentifier: "topImgIcon", searchInSubviews: true)?.constant = -3
            self.constraint(withIdentifier: "bottomLblTitle", searchInSubviews: true)?.constant = 1
            self.constraint(withIdentifier: "topLblDescription", searchInSubviews: true)?.constant = 1
            if !viewModel.selected {
                self.constraint(withIdentifier: "yLblSubtitle", searchInSubviews: true)?.constant = 20
            } else {
                self.constraint(withIdentifier: "yLblSubtitle", searchInSubviews: true)?.constant = -29
            }
        case 4:
            self.constraint(withIdentifier: "bottomLblTitle", searchInSubviews: true)?.constant = 5
            self.constraint(withIdentifier: "topLblDescription", searchInSubviews: true)?.constant = 5
            if !viewModel.selected {
                self.constraint(withIdentifier: "yLblSubtitle", searchInSubviews: true)?.constant = 20
            } else {
                self.constraint(withIdentifier: "yLblSubtitle", searchInSubviews: true)?.constant = -34
            }
        case 4.7:
            self.constraint(withIdentifier: "topImgIcon", searchInSubviews: true)?.constant = 5
            self.constraint(withIdentifier: "bottomImgCollapsed", searchInSubviews: true)?.constant = 5
            if !viewModel.selected {
                self.constraint(withIdentifier: "yLblSubtitle", searchInSubviews: true)?.constant = 20
            } else {
                self.constraint(withIdentifier: "yLblSubtitle", searchInSubviews: true)?.constant = -44
            }
        case 5.5:
            self.constraint(withIdentifier: "topImgIcon", searchInSubviews: true)?.constant = 10
            self.constraint(withIdentifier: "bottomImgCollapsed", searchInSubviews: true)?.constant = 10
            if !viewModel.selected {
                self.constraint(withIdentifier: "yLblSubtitle", searchInSubviews: true)?.constant = 20
            } else {
                self.constraint(withIdentifier: "yLblSubtitle", searchInSubviews: true)?.constant = -52
            }
        case 5.8:
            self.constraint(withIdentifier: "topImgIcon", searchInSubviews: true)?.constant = 12
            self.constraint(withIdentifier: "bottomImgCollapsed", searchInSubviews: true)?.constant = 12
            if !viewModel.selected {
                self.constraint(withIdentifier: "yLblSubtitle", searchInSubviews: true)?.constant = 21
            } else {
                self.constraint(withIdentifier: "yLblSubtitle", searchInSubviews: true)?.constant = -54
            }
        default:
            break
        }
    }
}
