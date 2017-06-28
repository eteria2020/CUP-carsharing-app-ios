//
//  SettingsCityItemCollectionViewCell.swift
//  Sharengo
//
//  Created by Dedecube on 28/06/17.
//  Copyright © 2017 Dedecube. All rights reserved.
//

import UIKit
import Boomerang
import RxSwift
import Action
import RxCocoa

class SettingsCityItemCollectionViewCell: UICollectionViewCell, ViewModelBindable {
    @IBOutlet fileprivate weak var lbl_title: UILabel!
    @IBOutlet fileprivate weak var img_icon: UIImageView!
    @IBOutlet fileprivate weak var view_icon: UIView!
    @IBOutlet fileprivate weak var btn_selectedLanguage: UIButton!
    
    var viewModel:ItemViewModelType?
    
    // MARK: - ViewModel methods
    
    func bind(to viewModel: ViewModelType?) {
        guard let viewModel = viewModel as? SettingsCityItemViewModel else {
            return
        }
        self.layoutIfNeeded()
        self.viewModel = viewModel
        self.lbl_title.styledText = viewModel.title
        
        if viewModel.selected == true
        {
            self.btn_selectedLanguage.setImage(UIImage(named: "ic_compass")!, for: .normal)
        }
        else
        {
            self.btn_selectedLanguage.setImage(nil, for: .normal)
        }
    }
    
    // MARK: - View methods
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    
}
