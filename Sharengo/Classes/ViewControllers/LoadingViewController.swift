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
    
    @IBOutlet fileprivate weak var img_loader: UIImageView!
    
	override func viewDidLoad() {
		super.viewDidLoad()
        
        var frames: [UIImage] = [UIImage]()
        for i in 1...47 {
            let image = UIImage(named: "LOADER_00\(i)")!
            frames.append(image)
        }
        img_loader.image = UIImage.animatedImage(with: frames, duration: 2)
    }
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
	}
}
