//
//  CollectionViewCell.swift
//  
//
//  Created by Stefano Mondino on 07/03/17.
//
//

import UIKit
import Boomerang
import RxSwift
import Action
import RxCocoa

class SettingsLanguageItemCollectionViewCell: UICollectionViewCell, ViewModelBindable {
    
    var viewModel:ItemViewModelType?
    var disposeBag = DisposeBag()
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    func bind(to viewModel: ViewModelType?) {
        guard let viewModel = viewModel as? SettingsLanguageItemViewModel else {
            return
        }
        self.viewModel = viewModel
    }
}
