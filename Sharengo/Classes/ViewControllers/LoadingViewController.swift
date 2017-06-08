//
//  LoadingViewController.swift
//  Sharengo
//
//  Created by Dedecube on 08/06/17.
//  Copyright © 2017 Dedecube. All rights reserved.
//

import UIKit
import SpinKit
import SnapKit

class LoadingViewController: UIViewController {
    @IBOutlet fileprivate weak var blackView: UIView!
    @IBOutlet fileprivate weak var containerView: UIView!
    
	override func viewDidLoad() {
		super.viewDidLoad()
        self.setupInterface()
	    UIView.animate(withDuration: 0.3, animations: { 
            self.blackView.alpha = 1.0
        }) 
    }
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
	}
	
	func setupInterface() {
        blackView.alpha = 0.0
        let spinner: RTSpinKitView = RTSpinKitView(style: RTSpinKitViewStyle.stylePulse, color: UIColor.white)
        containerView.backgroundColor = UIColor.clear
        containerView.addSubview(spinner)
        spinner.snp.makeConstraints { (make) -> Void in
            make.center.equalTo(containerView)
        }
	}
}
