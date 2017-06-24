//
//  MenuItemCollectionViewCell.swift
//  Sharengo
//
//  Created by Dedecube on 20/06/17.
//  Copyright © 2017 Dedecube. All rights reserved.
//

import UIKit
import Boomerang
import RxSwift
import Action
import RxCocoa

class MenuItemCollectionViewCell: UICollectionViewCell, ViewModelBindable {
    @IBOutlet fileprivate weak var lbl_title: UILabel!
    @IBOutlet fileprivate weak var view_icon: UIView!
    @IBOutlet fileprivate weak var img_icon: UIImageView!

    var viewModel:ItemViewModelType?
    
    // MARK: - ViewModel methods

    func bind(to viewModel: ViewModelType?) {
        guard let viewModel = viewModel as? MenuItemViewModel else {
            return
        }
        self.layoutIfNeeded()
        self.viewModel = viewModel
        self.lbl_title.styledText = viewModel.title
        self.img_icon.image = viewModel.icon ?? UIImage()
        self.view_icon.backgroundColor = UIColor.clear
        self.view_icon.layer.cornerRadius = self.view_icon.frame.size.width/2
        self.view_icon.layer.masksToBounds = true
        self.view_icon.layer.borderWidth = 1
        self.view_icon.layer.borderColor = Color.menuLabel.value.cgColor
    }

    // MARK: - View methods

    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = Color.menuTopBackground.value
    }
}