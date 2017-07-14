//
//  CategoryItemCollectionViewCell.swift
//  Sharengo
//
//  Created by Dedecube on 13/07/17.
//  Copyright © 2017 Dedecube. All rights reserved.
//

import UIKit
import Boomerang
import RxSwift
import Action
import RxCocoa

class CategoryItemCollectionViewCell: UICollectionViewCell, ViewModelBindable {
    @IBOutlet fileprivate weak var img_icon: UIImageView!
    @IBOutlet fileprivate weak var view_icon: UIView!
    @IBOutlet fileprivate weak var lbl_title: UILabel!
    @IBOutlet fileprivate weak var view_topBorder: UIView!
    @IBOutlet fileprivate weak var view_leftBorder: UIView!
    @IBOutlet fileprivate weak var view_rightBorder: UIView!
    @IBOutlet fileprivate weak var view_bottomBorder: UIView!
    
    var viewModel:ItemViewModelType?
    
    // MARK: - ViewModel methods
    
    func bind(to viewModel: ViewModelType?) {
        guard let viewModel = viewModel as? CategoryItemViewModel else {
            return
        }
        self.layoutIfNeeded()
        self.viewModel = viewModel
        
        if viewModel.published
        {
            self.view_icon.backgroundColor = viewModel.color // Color.categoriesItemIconBackground.value
            self.lbl_title.bonMotStyle?.color = Color.categoriesItemTitle.value
        }
        else
        {
            self.view_icon.backgroundColor = Color.categoriesItemIconBackgroundDisabled.value
            self.lbl_title.bonMotStyle?.color = Color.categoriesItemTitleDisabled.value
        }
        
        self.backgroundColor = Color.categoriesBackground.value
        
        self.lbl_title.styledText = viewModel.title
        
        self.view_icon.layer.cornerRadius = self.view_icon.frame.size.width/2
        self.view_icon.layer.masksToBounds = true
        self.view_topBorder.backgroundColor = Color.categoriesItemBorderBackground.value
        self.view_bottomBorder.backgroundColor = Color.categoriesItemBorderBackground.value
        self.view_leftBorder.backgroundColor = Color.categoriesItemBorderBackground.value
        self.view_rightBorder.backgroundColor = Color.categoriesItemBorderBackground.value
        
        if let icon = viewModel.icon,
            let url = URL(string: icon)
        {
            do {
                let data = try Data(contentsOf: url)
                if let image = UIImage(data: data) {
                    // TODO: caricare la gif
                    if viewModel.published {
                        self.img_icon.image = image.tinted(ColorBrand.white.value)
                    } else {
                        self.img_icon.image = image.tinted(UIColor(hexString: "#aca59d"))
                    }
                }
            } catch {
            }
        }
    }
    
    // MARK: - View methods
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
