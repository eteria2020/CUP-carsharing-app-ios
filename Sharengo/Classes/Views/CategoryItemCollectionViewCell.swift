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
import Gifu

class CategoryItemCollectionViewCell: UICollectionViewCell, ViewModelBindable {
    @IBOutlet fileprivate weak var img_icon: UIImageView!
    @IBOutlet fileprivate weak var gif_icon: GIFImageView!
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

        self.img_icon.image = nil
        self.gif_icon.image = nil
        self.img_icon.alpha = 0.0
        self.gif_icon.alpha = 0.0
        self.gif_icon.stopAnimatingGIF()
        
        DispatchQueue.global(qos: .background).async {
            if viewModel.published {
                if let icon = viewModel.gif,
                    let url = URL(string: icon)
                {
                    do {
                        let data = try Data(contentsOf: url)
                        DispatchQueue.main.async {
                            self.gif_icon.animate(withGIFData: data)
                            UIView.animate(withDuration: 0.25, animations: {
                                self.gif_icon.alpha = 1.0
                            })
                        }
                    } catch {
                    }
                }
            } else {
                if let icon = viewModel.icon,
                    let url = URL(string: icon)
                {
                    do {
                        let data = try Data(contentsOf: url)
                        if let image = UIImage(data: data) {
                            DispatchQueue.main.async {
                                self.img_icon.image = image.tinted(UIColor(hexString: "#aca59d"))
                                UIView.animate(withDuration: 0.25, animations: {
                                    self.img_icon.alpha = 1.0
                                })
                            }
                        }
                    } catch {
                    }
                }
            }
        }
    }
    
    // MARK: - View methods
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
