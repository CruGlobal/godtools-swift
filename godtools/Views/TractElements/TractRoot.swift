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
    
    override func setupView(properties: [String: Any]) {
        self.frame = buildFrame()
    }
    
    // MARK: - Helpers
    
    fileprivate func buildFrame() -> CGRect {
        return CGRect(x: 0.0,
                      y: self.yStartPosition,
                      width: self.width,
                      height: self.height)
    }
    
    func sendMessageToView(tag: Int) {
        let view = self.viewWithTag(tag)
        if (view?.isKind(of: BaseTractElement.self))! {
            (view as! BaseTractElement).receiveMessage()
        }
    }
    
}
