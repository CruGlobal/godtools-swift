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
        let height = self.frame.size.height
        backgroundColor = .gtWhite
        
        let rootElement: TractRoot = TractRoot(data: self.data!["page"], withMaxHeight: height)
        
        let contentView: UIView = rootElement.render()
        self.addSubview(contentView)
    }
}
