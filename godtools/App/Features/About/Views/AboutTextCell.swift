//
//  AboutTextCell.swift
//  godtools
//
//  Created by Levi Eggert on 7/9/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class AboutTextCell: UITableViewCell {
    
    static let nibName: String = "AboutTextCell"
    static let reuseIdentifier: String = "AboutTextCellReuseIdentifier"
    
    @IBOutlet weak private var aboutTextLabel: UILabel!
    
    func configure(viewModel: AboutTextCellViewModel) {
        
        aboutTextLabel.text = viewModel.text
        aboutTextLabel.setLineSpacing(lineSpacing: 3)
    }
}
