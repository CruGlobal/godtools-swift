//
//  TractModals.swift
//  godtools
//
//  Created by Devserker on 5/16/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import UIKit

class TractModals: BaseTractElement {
    
    // MARK: - Setup
    
    var properties = TractModalsProperties()
    
    override func loadStyles() {
        self.isHidden = true
    }
    
    override func buildFrame() -> CGRect {
        loadFrameProperties()
        return (UIApplication.shared.keyWindow?.frame)!
    }
    
    override func render() -> UIView {
        TractBindings.addBindings(self)
        return self
    }

}
