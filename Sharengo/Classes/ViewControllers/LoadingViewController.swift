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

/**
 The Loading class is a view that adds a custom loading during operations involving communication with the server
 */
public class LoadingViewController: UIViewController {
    @IBOutlet fileprivate weak var img_loader: UIImageView!
    
    // MARK: - View methods
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        var frames: [UIImage] = [UIImage]()
        for i in 1...47 {
            let image = UIImage(named: "LOADER_00\(i)")!
            frames.append(image)
        }
        img_loader.image = UIImage.animatedImage(with: frames, duration: 2)
    }
	
	override public func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
	}
}
