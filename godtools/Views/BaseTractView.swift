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
    var colors: TractColors?
    var configurations = TractConfigurations()
    var contentView: TractRoot?
    
    override func layoutSubviews() {
        let height = self.frame.size.height
        backgroundColor = .gtWhite
        
        self.contentView = TractRoot(startWithData: self.data!["page"],
                                     withMaxHeight: height,
                                     colors: self.colors!,
                                     configurations: self.configurations)
        
        self.addSubview(self.contentView!.render())
    }
    
    func pageId() -> String {
        return self.contentView!.pageId
    }
    
}
