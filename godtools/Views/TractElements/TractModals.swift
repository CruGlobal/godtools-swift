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
    
    override func setupView(properties: Dictionary<String, Any>) {
        self.frame = buildFrame()
        self.isHidden = true
    }
    
    override func render() -> UIView {
        TractBindings.addBindings(self)
        return self
    }
    
    // MARK: - Helpers
    
    fileprivate func buildFrame() -> CGRect {
        return (UIApplication.shared.keyWindow?.frame)!
    }

}
