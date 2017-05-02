//
//  BaseTractView.swift
//  godtools
//
//  Created by Ryan Carlson on 4/26/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation
import UIKit
import SWXMLHash

class BaseTractView: UIView {
    
    var data: XMLIndexer?
    
    override func layoutSubviews() {
        backgroundColor = .gtWhite
        
        let yPosition: CGFloat = 0.0
        let rootElement: TractRoot = TractRoot(data: self.data!["page"], startOnY: yPosition)
        
        let contentView: UIView = rootElement.render()
        self.addSubview(contentView)
    }
}
