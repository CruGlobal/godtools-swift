//
//  TractEmails.swift
//  godtools
//
//  Created by Pablo Marti on 6/6/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import UIKit

class TractEmails: BaseTractElement {
    
    // MARK: - Setup
    
    override func loadStyles() {
        self.isHidden = true
    }
    
    override func buildFrame() -> CGRect {
        return CGRect(x: 0.0, y: 0.0, width: 0.0, height: 0.0)
    }
    
    override func render() -> UIView {
        TractBindings.addBindings(self)
        return self
    }

}
