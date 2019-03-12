//
//  SearchBarCollectionViewCell.swift
//  Sharengo
//
//  Created by Dedecube on 02/06/17.
//  Copyright © 2017 Dedecube. All rights reserved.
//

import UIKit

import RxSwift
import Action
import RxCocoa

class SearchBarCollectionViewCell: UICollectionViewCell, ViewModelBindable {
    
    var viewModel: ItemViewModelType?

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var view_separator: UIView!

    func bind(to viewModel: ViewModelType?) {
        guard let viewModel = viewModel as? SearchBarItemViewModel else { return }
        self.viewModel = viewModel
        self.titleLabel.styledText = viewModel.name
        self.iconImage.image = UIImage(named: viewModel.image ?? "") ?? UIImage()
        
        self.view_separator.isHidden = false
        if viewModel.name == "lbl_favouritesNoFavorites".localized() {
            self.view_separator.isHidden = true
        }
    }
}
