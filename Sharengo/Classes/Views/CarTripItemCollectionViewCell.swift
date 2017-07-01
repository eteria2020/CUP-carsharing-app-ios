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

class CarTripItemCollectionViewCell: UICollectionViewCell, ViewModelBindable {
    @IBOutlet fileprivate weak var img_iconBackground: UIImageView!
    @IBOutlet fileprivate weak var img_icon: UIImageView!
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
        
        self.lbl_title.styledText = viewModel.title
        self.lbl_subtitle.styledText = viewModel.subtitle
        self.lbl_description.styledText = viewModel.description
    }
    
    // MARK: - View methods
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
