//
//  FeedItemCollectionViewCell.swift
//  Sharengo
//
//  Created by Dedecube on 12/07/17.
//  Copyright © 2017 Dedecube. All rights reserved.
//

import UIKit

import RxSwift
import Action
import RxCocoa
import BonMot

class FeedItemCollectionViewCell: UICollectionViewCell, ViewModelBindable {
    @IBOutlet fileprivate weak var view_containerBackgroundImage: UIView!
    @IBOutlet fileprivate weak var img_background: UIImageView!
    @IBOutlet fileprivate weak var view_overlayBackgroundImage: UIView!
    @IBOutlet fileprivate weak var view_containerClaim: UIView!
    @IBOutlet fileprivate weak var lbl_claim: UILabel!
    @IBOutlet fileprivate weak var img_claim: UIImageView!
    @IBOutlet fileprivate weak var view_bottomContainer: UIView!
    @IBOutlet fileprivate weak var lbl_bottom: UILabel!
    @IBOutlet fileprivate weak var img_favorite: UIImageView!
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
        
        if let icon = viewModel.icon,
            let url = URL(string: icon)
        {
            do {
                let data = try Data(contentsOf: url)
                if let image = UIImage(data: data) {
                    self.img_icon.image = image.tinted(Color.feedsItemIconBorderBackground.value)
                }
            } catch {
            }
        }
        
        self.view_containerBackgroundImage.backgroundColor = viewModel.color

        self.img_background.alpha = 0.0
        DispatchQueue.global(qos: .background).async {
            if let image = viewModel.image,
                let url = URL(string: image)
            {
                do {
                    let data = try Data(contentsOf: url)
                    if let image = UIImage(data: data) {
                        DispatchQueue.main.async {
                            self.img_background.image = image
                            UIView.animate(withDuration: 0.25, animations: {
                                self.img_background.alpha = 1.0
                            })
                        }
                    }
                } catch {
                }
            }
        }
        
        self.view_overlayBackgroundImage.backgroundColor = viewModel.color.withAlphaComponent(0.5)

        let titleStyle = StringStyle(.font(Font.feedsItemTitle.value), .color(viewModel.color), .alignment(.left))
        let dateStyle = StringStyle(.font(Font.feedsItemDate.value), .color(Color.feedsItemDate.value), .alignment(.left))
        let subtitleStyle = StringStyle(.font(Font.feedsItemSubtitle.value), .color(Color.feedsItemSubtitle.value), .alignment(.left))
        let descriptionStyle = StringStyle(.font(Font.feedsItemDescription.value), .color(Color.feedsItemDescription.value), .alignment(.left))
        let advantageStyle = StringStyle(.font(Font.feedsItemAdvantage.value), .color(viewModel.advantageColor), .alignment(.left))
    
        self.lbl_bottom.bonMotStyle = StringStyle(.font(Font.feedsItemDescription.value), .color(Color.feedsItemDescription.value), .alignment(.center),.xmlRules([.style("title", titleStyle), .style("date", dateStyle), .style("subtitle", subtitleStyle), .style("description", descriptionStyle), .style("advantage", advantageStyle)]))
        self.lbl_bottom.styledText = viewModel.bottomText
        
        self.view_icon.backgroundColor = viewModel.color
        self.view_icon.layer.cornerRadius = self.view_icon.frame.size.width/2
        self.view_icon.layer.masksToBounds = true
        self.view_icon.layer.borderWidth = 1
        self.view_icon.layer.borderColor = Color.feedsItemIconBorderBackground.value.cgColor
        
        if viewModel.favourited
        {
            self.img_favorite.alpha = 1.0
        }
        else
        {
            self.img_favorite.alpha = 0.0
        }
    }
}
