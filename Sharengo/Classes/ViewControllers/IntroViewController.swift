//
//  IntroViewController.swift
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

// TODO: le gif dovrebbero avere altezza proporzionale?

class IntroViewController : UIViewController, ViewModelBindable {
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
    
    // MARK: - Animation methods
    
    fileprivate func executeLongIntro() {
        var bottomTitle1: CGFloat = 120.0
        var bottomTitle2: CGFloat = 70.0
        var bottomTitle3: CGFloat = 80.0
        switch Device().diagonal {
        case 3.5:
            bottomTitle1 = 90.0
            bottomTitle2 = 40.0
            bottomTitle3 = 50.0
        case 4:
            bottomTitle1 = 100.0
            bottomTitle2 = 50.0
            bottomTitle3 = 60.0
        default:
            break
        }
        self.img_intro.animate(withGIFNamed: "INTRO LUNGA INIZIO.gif", loopCount: 1)
        var dispatchTime = DispatchTime.now() + 2.8
        DispatchQueue.main.asyncAfter(deadline: dispatchTime) {
            self.img_intro.animate(withGIFNamed: "INTRO LUNGA FINE.gif", loopCount: 1)
            self.lbl_title1.alpha = 1.0
            UIView.animate(withDuration: 0.8, animations: {
                self.view.constraint(withIdentifier: "bottomLblTitle1", searchInSubviews: true)?.constant = bottomTitle1
                self.view.layoutIfNeeded()
            })
            dispatchTime = DispatchTime.now() + 1
            DispatchQueue.main.asyncAfter(deadline: dispatchTime) {
                self.lbl_title2.alpha = 1.0
                UIView.animate(withDuration: 0.8, animations: {
                    self.view.constraint(withIdentifier: "bottomLblTitle2", searchInSubviews: true)?.constant = bottomTitle2
                    self.view.layoutIfNeeded()
                })
                dispatchTime = DispatchTime.now() + 1
                DispatchQueue.main.asyncAfter(deadline: dispatchTime) {
                    self.lbl_title3.alpha = 1.0
                    UIView.animate(withDuration: 0.8, animations: {
                        self.lbl_title1.alpha = 0.0
                        self.lbl_title2.alpha = 0.0
                        self.view.constraint(withIdentifier: "bottomLblTitle3", searchInSubviews: true)?.constant = bottomTitle3
                        self.view.layoutIfNeeded()
                    })
                    dispatchTime = DispatchTime.now() + 1
                    DispatchQueue.main.asyncAfter(deadline: dispatchTime) {
                        UIView.animate(withDuration: 0.8, animations: {
                            self.lbl_title3.alpha = 0.0
                        })
                    }
                }
            }
            dispatchTime = DispatchTime.now() + 4.8
            DispatchQueue.main.asyncAfter(deadline: dispatchTime) {
                self.img_intro.stopAnimating()
                UserDefaults.standard.set(true, forKey: "LongIntro")
                UIView.animate(withDuration: 0.5, animations: {
                    self.view.frame.origin.y = -UIScreen.main.bounds.size.height
                })
            }
        }
    }
    
    fileprivate func executeShortIntro() {
        self.img_intro.animate(withGIFNamed: "INTRO BREVE.gif", loopCount: 1)
        let dispatchTime = DispatchTime.now() + 1.3
        DispatchQueue.main.asyncAfter(deadline: dispatchTime) {
            UIView.animate(withDuration: 0.5, animations: {
                self.view.frame.origin.y = -UIScreen.main.bounds.size.height
            })
        }
    }
}
