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
    
    var contentView: TractRoot?
    
    init(frame: CGRect, data: XMLIndexer, colors: TractColors, configurations: TractConfigurations) {
        super.init(frame: frame)
        
        let height = self.frame.size.height
        self.contentView = TractRoot(startWithData: data,
                                     withMaxHeight: height,
                                     colors: colors,
                                     configurations: configurations)
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
