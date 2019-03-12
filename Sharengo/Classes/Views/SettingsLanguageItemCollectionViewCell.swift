//
//  SettingsLanguageItemCollectionViewCell.swift
//  Sharengo
//
//  Created by Dedecube on 27/06/17.
//  Copyright © 2017 Dedecube. All rights reserved.
//

import UIKit

import RxSwift
import Action
import RxCocoa

/**
 The Setting language item class is the visual representation of a setting language's option
 */
public class SettingsLanguageItemCollectionViewCell: UICollectionViewCell, ViewModelBindable {
    @IBOutlet fileprivate weak var lbl_title: UILabel!
    @IBOutlet fileprivate weak var btn_selectedLanguage: UIButton!
    /// ViewModel variable used to represents the data
    public var viewModel:ItemViewModelType?
    
    // MARK: - ViewModel methods
    
    public func bind(to viewModel: ViewModelType?) {
        guard let viewModel = viewModel as? SettingsLanguageItemViewModel else {
            return
        }
        self.layoutIfNeeded()
        self.viewModel = viewModel
        self.lbl_title.styledText = viewModel.title
        if viewModel.selected == true {
            self.btn_selectedLanguage.setImage(UIImage(named: "ic_citta_selezionata")!, for: .normal)
        } else {
            self.btn_selectedLanguage.setImage(nil, for: .normal)
        }
    }
}
