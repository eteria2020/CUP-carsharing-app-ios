//
//  HomeViewController.swift
//  Sharengo
//
//  Created by Dedecube on 06/06/17.
//  Copyright © 2017 Dedecube. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Boomerang
import YYWebImage

class IntroViewController : UIViewController, ViewModelBindable {
    @IBOutlet fileprivate weak var img_intro: YYAnimatedImageView!
    
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
        if UserDefaults.standard.bool(forKey: "LongIntro") == false {
            if let url = Bundle.main.url(forResource: "INTRO LUNGA INIZIO", withExtension: "gif") {
                self.img_intro.yy_imageURL = url
                var dispatchTime = DispatchTime.now() + 3
                DispatchQueue.main.asyncAfter(deadline: dispatchTime) {
                    if let url = Bundle.main.url(forResource: "INTRO LUNGA FINE", withExtension: "gif") {
                        self.img_intro.yy_imageURL = url
                        dispatchTime = DispatchTime.now() + 4
                        DispatchQueue.main.asyncAfter(deadline: dispatchTime) {
                            UserDefaults.standard.set(true, forKey: "LongIntro")
                            UIView.animate(withDuration: 0.5, animations: {
                                self.view.frame.origin.y = -UIScreen.main.bounds.size.height
                            })
                        }
                    }
                }
            }
        } else {
            if let url = Bundle.main.url(forResource: "INTRO BREVE", withExtension: "gif") {
                self.img_intro.yy_imageURL = url
                let dispatchTime = DispatchTime.now() + 1
                DispatchQueue.main.asyncAfter(deadline: dispatchTime) {
                    UIView.animate(withDuration: 0.5, animations: {
                        self.view.frame.origin.y = -UIScreen.main.bounds.size.height
                    })
                }
            }
        }
    }
}
