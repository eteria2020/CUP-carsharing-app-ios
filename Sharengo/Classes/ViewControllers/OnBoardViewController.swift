//
//  OnBoardViewController.swift
//  Sharengo
//
//  Created by Dedecube on 06/06/17.
//  Copyright © 2017 Dedecube. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Boomerang
import Gifu

class OnBoardViewController : UIViewController, ViewModelBindable {
    @IBOutlet fileprivate weak var img_background: GIFImageView!
    @IBOutlet fileprivate weak var lbl_description: UILabel!
    @IBOutlet fileprivate weak var btn_skip: UIButton!
    @IBOutlet fileprivate weak var pgc_steps: UIPageControl!
    
    var viewModel: OnBoardViewModel?
    
    // MARK: - ViewModel methods
    
    func bind(to viewModel: ViewModelType?) {
        guard let viewModel = viewModel as? OnBoardViewModel else {
            return
        }
        self.viewModel = viewModel
    }
    
    // MARK: - View methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.layoutIfNeeded()
        self.lbl_description.styledText = "lbl_introTitle1".localized()
        self.lbl_description.alpha = 0.0
    }
}
