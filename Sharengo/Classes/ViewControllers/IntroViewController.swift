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
        /*
        viewModel.selection.elements.subscribe(onNext:{ selection in
            switch selection {
            case .viewModel(let viewModel):
                Router.from(self,viewModel: viewModel).execute()
            }
        }).addDisposableTo(self.disposeBag)
        */
    }
    
    // MARK: - View methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.layoutIfNeeded()
         if UserDefaults.standard.bool(forKey: "longIntro") == false {
            do {
                if let url = Bundle.main.url(forResource: "INTRO LUNGA INIZIO", withExtension: "gif") {
                    self.img_intro.yy_imageURL = url
                    let dispatchTime = DispatchTime.now() + 3
                    DispatchQueue.main.asyncAfter(deadline: dispatchTime) {
                        if let url = Bundle.main.url(forResource: "INTRO LUNGA FINE", withExtension: "gif") {
                            self.img_intro.yy_imageURL = url
                        }
                    }

                }
            } catch {}
        }
    }
}
