//
//  TractPageContainer.swift
//  godtools
//
//  Created by Pablo Marti on 11/7/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation
import UIKit
import SWXMLHash

class TractPageContainer: BaseTractElement {
    
    // MARK: - Setup
    static var marginBottom: CGFloat {
        return UIDevice.current.iPhoneX() ? CGFloat(44.0) : CGFloat(0.0)
    }
    
    override func propertiesKind() -> TractProperties.Type {
        return TractPageProperties.self
    }
    
    override func loadFrameProperties() {
        self.elementFrame.x = 0.0
        self.elementFrame.width = parentWidth()
    }
    
    override func updateFrameHeight() {
        self.elementFrame.height = self.parent!.getMaxHeight() - TractPage.statusbarHeight
        self.frame = self.elementFrame.getFrame()
    }
    
    override func startingYPos() -> CGFloat {
        return TractPage.navbarHeight + TractViewController.progressViewMarginBottom
    }
    
    override func loadStyles() {
        self.clipsToBounds = true
    }
    
    // MARK: - Helpers
    
    func pageProperties() -> TractPageProperties {
        return self.properties as! TractPageProperties
    }
    
}
