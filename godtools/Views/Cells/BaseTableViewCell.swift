//
//  BaseTableViewCell.swift
//  godtools
//
//  Created by Ryan Carlson on 4/16/18.
//  Copyright © 2018 Cru. All rights reserved.
//

import Foundation

class BaseTableViewCell: UITableViewCell {
    override func awakeFromNib() {
        super.awakeFromNib()
        addAccessibilityIdentifiers()
    }
    
    func addAccessibilityIdentifiers() {
        
    }
}
