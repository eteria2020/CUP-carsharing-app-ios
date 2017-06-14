//
//  ProfileTableViewCell.swift
//  Sharengo
//
//  Created by Dedecube on 14/06/17.
//  Copyright © 2017 Dedecube. All rights reserved.
//

import UIKit

class ProfileTableViewCell : UITableViewCell {
    
    @IBOutlet fileprivate weak var titleLabel: UILabel!
    
    // MARK: - View methods
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
    }
    
    // MARK: - Setup methods
    
    func setupWith(title: String)
    {
        self.titleLabel.text = title
    }
}
