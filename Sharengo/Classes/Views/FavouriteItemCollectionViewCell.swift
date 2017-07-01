//
//  FavouriteItemCollectionViewCell.swift
//  Sharengo
//
//  Created by Dedecube on 27/06/17.
//  Copyright © 2017 Dedecube. All rights reserved.
//

import UIKit
import Boomerang
import RxSwift
import Action
import RxCocoa

class FavouriteItemCollectionViewCell: UICollectionViewCell, ViewModelBindable {
    @IBOutlet fileprivate weak var lbl_title: UILabel!
    @IBOutlet fileprivate weak var iconImage: UIImageView!

    var viewModel:ItemViewModelType?
    
    // MARK: - ViewModel methods
    
    func bind(to viewModel: ViewModelType?) {
        guard let viewModel = viewModel as? FavouriteItemViewModel else {
            return
        }
        self.layoutIfNeeded()
        self.viewModel = viewModel
        self.lbl_title.styledText = viewModel.title
        self.iconImage.image = UIImage(named: viewModel.image ?? "")?.tinted(ColorBrand.black.value) ?? UIImage()
    }
    
    // MARK: - View methods
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
