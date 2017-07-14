//
//  FeedItemCollectionViewCell.swift
//  Sharengo
//
//  Created by Dedecube on 12/07/17.
//  Copyright © 2017 Dedecube. All rights reserved.
//

import UIKit
import Boomerang
import RxSwift
import Action
import RxCocoa

class FeedItemCollectionViewCell: UICollectionViewCell, ViewModelBindable {
    @IBOutlet fileprivate weak var view_containerBackgroundImage: UIView!
    @IBOutlet fileprivate weak var img_background: UIImageView!
    @IBOutlet fileprivate weak var view_overlayBackgroundImage: UIView!
    @IBOutlet fileprivate weak var view_containerClaim: UIView!
    @IBOutlet fileprivate weak var lbl_claim: UILabel!
    @IBOutlet fileprivate weak var img_claim: UIImageView!
    @IBOutlet fileprivate weak var view_bottomContainer: UIView!
    @IBOutlet fileprivate weak var lbl_bottom: UILabel!
    @IBOutlet fileprivate weak var img_icon: UIImageView!
    @IBOutlet fileprivate weak var view_icon: UIView!
    
    var viewModel:ItemViewModelType?
    
    // MARK: - ViewModel methods
    
    func bind(to viewModel: ViewModelType?) {
        guard let viewModel = viewModel as? FeedItemViewModel else {
            return
        }
        self.layoutIfNeeded()
        self.viewModel = viewModel

        if viewModel.claim != nil && viewModel.claim?.isEmpty == false
        {
            self.view_containerClaim.isHidden = false
            self.lbl_claim.styledText = viewModel.claim
            self.img_claim.image = self.img_claim.image?.tinted(viewModel.color)
        }
        else
        {
            self.view_containerClaim.isHidden = true
        }
        
        self.lbl_bottom.bonMotStyleName = "feedsItemBottom"
        self.lbl_bottom.styledText = viewModel.bottomText
        self.img_icon.image = viewModel.icon ?? UIImage()
        
        if let image = viewModel.image,
            let url = URL(string: image)
        {
            do {
                let data = try Data(contentsOf: url)
                if let image = UIImage(data: data) {
                    self.img_background.image = image
                }
            } catch {
            }
        }
        
        self.view_overlayBackgroundImage.backgroundColor = viewModel.color.withAlphaComponent(0.5)

        self.view_icon.backgroundColor = viewModel.color
        self.view_icon.layer.cornerRadius = self.view_icon.frame.size.width/2
        self.view_icon.layer.masksToBounds = true
        self.view_icon.layer.borderWidth = 1
        self.view_icon.layer.borderColor = Color.feedsItemIconBorderBackground.value.cgColor
    }
    
    // MARK: - View methods
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
