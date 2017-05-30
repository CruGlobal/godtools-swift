//
//  TractRoot.swift
//  godtools
//
//  Created by Devserker on 4/27/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation
import UIKit
import SWXMLHash

//  NOTES ABOUT THE COMPONENT
//  * This component must always be initialized with: init(data: XMLIndexer, withMaxHeight height: CGFloat)

class TractRoot: BaseTractElement {
    
    var pageId: String = ""
    
    override func setupView(properties: [String: Any]) {
        super.setupView(properties: properties)
        self.pageId = properties["id"] as! String
    }
    
    override func buildFrame() -> CGRect {
        return CGRect(x: 0.0,
                      y: self.yStartPosition,
                      width: self.width,
                      height: self.height)
    }
    
    override func elementListeners() -> [String]? {
        return [self.pageId]
    }
    
}
