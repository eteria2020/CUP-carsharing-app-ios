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
import DeviceKit

class OnBoardViewController : UIViewController, ViewModelBindable {
    @IBOutlet fileprivate weak var img_intro: GIFImageView!
    @IBOutlet fileprivate weak var lbl_title1: UILabel!
    @IBOutlet fileprivate weak var lbl_title2: UILabel!
    @IBOutlet fileprivate weak var lbl_title3: UILabel!
    
    var viewModel: IntroViewModel?
    
    // MARK: - ViewModel methods
    
    func bind(to viewModel: ViewModelType?) {
        guard let viewModel = viewModel as? IntroViewModel else {
            return
        }
        self.viewModel = viewModel
    }
    
    // MARK: - View methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.layoutIfNeeded()
        self.view.constraint(withIdentifier: "bottomLblTitle1", searchInSubviews: true)?.constant = -110
        self.view.constraint(withIdentifier: "bottomLblTitle2", searchInSubviews: true)?.constant = -160
        self.view.constraint(withIdentifier: "bottomLblTitle3", searchInSubviews: true)?.constant = -150
        self.lbl_title1.styledText = "lbl_introTitle1".localized()
        self.lbl_title1.alpha = 0.0
        self.lbl_title2.styledText = "lbl_introTitle2".localized()
        self.lbl_title2.alpha = 0.0
        self.lbl_title3.styledText = "lbl_introTitle3".localized()
        self.lbl_title3.alpha = 0.0
        if UserDefaults.standard.bool(forKey: "LongIntro") == false {
            self.executeLongIntro()
        } else {
            self.executeShortIntro()
        }
    }    
}
