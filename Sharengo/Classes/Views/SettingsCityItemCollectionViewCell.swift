//
//  SettingsCityItemCollectionViewCell.swift
//  Sharengo
//
//  Created by Dedecube on 28/06/17.
//  Copyright © 2017 Dedecube. All rights reserved.
//

import UIKit

import RxSwift
import Action
import RxCocoa

/**
 The Setting city item class is the visual representation of a setting city's option
 */
public class SettingsCityItemCollectionViewCell: UICollectionViewCell, ViewModelBindable {
    @IBOutlet fileprivate weak var lbl_title: UILabel!
    @IBOutlet fileprivate weak var img_icon: UIImageView!
    @IBOutlet fileprivate weak var view_icon: UIView!
    @IBOutlet fileprivate weak var btn_selected: UIButton!
    @IBOutlet fileprivate weak var view_selected: UIView!
    /// ViewModel variable used to represents the data
    public var viewModel:SettingsCityItemViewModel?
    
    // MARK: - ViewModel methods
    
    public func bind(to viewModel: ViewModelType?) {
        guard let viewModel = viewModel as? SettingsCityItemViewModel else {
            return
        }
        self.layoutIfNeeded()
        self.viewModel = viewModel
        switch self.viewModel!.identifier! {
        //Milano
        case "5":
            self.img_icon.image = UIImage(named: "ic_cluster_milan")!
        //Firenze
        case "6":
              self.img_icon.image = UIImage(named: "ic_cluster_firence")!
        //Roma
        case "7":
              self.img_icon.image = UIImage(named: "ic_cluster_rome")!
        //Modena
        case "8":
              self.img_icon.image = UIImage(named: "ic_cluster_modena")!
        default:
            break
        }
       
        self.view_icon.backgroundColor = nil
        self.view_icon.layer.cornerRadius = self.view_icon.frame.size.width/2
        self.view_icon.layer.masksToBounds = true
        self.view_icon.layer.borderWidth = 0
        self.view_icon.layer.borderColor = Color.settingItemLabel.value.cgColor
        self.lbl_title.styledText = viewModel.title
        if let icon = viewModel.icon,
            let url = URL(string: icon)
        {
            do {
                let data = try Data(contentsOf: url)
                if let image = UIImage(data: data) {
                    self.img_icon.image = image
                }
            } catch {
            }
        }
        if viewModel.selected == true
        {
            self.btn_selected.setImage(UIImage(named: "ic_citta_selezionata")!, for: .normal)
        }
        else
        {
            self.btn_selected.setImage(nil, for: .normal)
        }
    }
}
