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
    
    override func propertiesKind() -> TractProperties.Type {
        return TractEmailsProperties.self
    }
    
    override func loadStyles() {
        self.isHidden = true
    }
    
    override func render() -> UIView {
        TractBindings.addBindings(self)
        return self
    }

}
