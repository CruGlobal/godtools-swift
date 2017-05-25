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
    var configurations: TractConfigurations?
    var contentView: TractRoot?
    
    init(frame: CGRect, data: XMLIndexer, colors: TractColors, configurations: TractConfigurations) {
        super.init(frame: frame)
        
        self.data = data
        self.colors = colors
        self.configurations = configurations
        
        let height = self.frame.size.height
        self.contentView = TractRoot(startWithData: self.data!,
                                     withMaxHeight: height,
                                     colors: self.colors!,
                                     configurations: self.configurations!)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        backgroundColor = .gtWhite        
        self.addSubview(self.contentView!.render())
    }
    
    func pageId() -> String {
        return self.contentView!.pageId
    }
    
}
