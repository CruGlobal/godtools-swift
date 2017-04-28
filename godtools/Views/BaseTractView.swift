//
//  BaseTractView.swift
//  godtools
//
//  Created by Ryan Carlson on 4/26/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation
import UIKit

class BaseTractView: UIView {
    
    var data: Dictionary<String, Any>?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func layoutSubviews() {
        backgroundColor = .orange
        
        let yPosition: CGFloat = 0.0
        let rootElement: TractRoot = TractRoot(data: self.data!, startOnY: yPosition)
        self.addSubview(rootElement.render())
    }
}
