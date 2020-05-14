//
//  TractPageContainer.swift
//  godtools
//
//  Created by Pablo Marti on 11/7/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import UIKit
import SWXMLHash

// TODO: Is TractPageContainer needed? ~Levi
class TractPageContainer: BaseTractElement {
    
    override var properties: TractProperties {
        get {
            return (self.parent?.properties)!
        }
        set { }
    }
    
    // MARK: - Setup
    
    static var marginBottom: CGFloat {
        // TODO: I don't like this because what if there is a new device in the future.  ~Levi
        let iphoneXMarginBottomToSafeArea: CGFloat = 44
        return UIDevice.current.iPhoneWithNotch() ? iphoneXMarginBottomToSafeArea : CGFloat(0.0)
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
        return TractPage.navbarHeight
    }
    
    override func loadStyles() {
        self.clipsToBounds = true
    }
    
    override func setupParallelElement() {
        if (self.parent!.parallelElement != nil) {
            self.parallelElement = self.parent!.parallelElement!.elements?[0]
        }
    }
}
