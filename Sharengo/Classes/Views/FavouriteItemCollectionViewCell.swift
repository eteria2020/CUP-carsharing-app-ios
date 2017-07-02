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
    @IBOutlet fileprivate weak var view_action1: UIView!
    @IBOutlet fileprivate weak var view_action2: UIView!
    @IBOutlet fileprivate weak var icn_action1: UIImageView!
    @IBOutlet fileprivate weak var icn_action2: UIImageView!
    @IBOutlet weak var btn_action1: UIButton!
    @IBOutlet weak var btn_action2: UIButton!
    
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
        self.view_action1.layer.cornerRadius = self.view_action1.frame.size.width/2
        self.view_action1.layer.masksToBounds = true
        self.view_action2.layer.cornerRadius = self.view_action2.frame.size.width/2
        self.view_action2.layer.masksToBounds = true
        
        if viewModel.favourite {
            icn_action1.image = UIImage(named: "ic_modifica")
        } else {
            icn_action1.image = UIImage(named: "ic_favourites")
        }
    }
    
    // MARK: - View methods
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
