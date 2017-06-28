//
//  TractForm.swift
//  godtools
//
//  Created by Devserker on 5/11/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import UIKit

class TractForm: BaseTractElement {

    // MARK: - Object properties
    
    var formElements = [BaseTractElement]()
    
    // MARK - Setup
    
    override func propertiesKind() -> TractProperties.Type {
        return TractFormProperties.self
    }
    
    override func loadFrameProperties() {
        self.elementFrame.x = 0.0
        self.elementFrame.width = parentWidth()
        self.elementFrame.xMargin = TractCard.xPaddingConstant
    }
    
    override func render() -> UIView {
        for element in self.elements! {
            self.addSubview(element.render())
        }
        
        loadParallelElementState()
        TractBindings.addBindings(self)
        
        for element in formElements {
            if element.isKind(of: TractInput.self) {
                let tractInput = element as? TractInput
                tractInput?.updateTextFieldReturnKey()
            }
        }
        
        return self
    }

    // MARK: - Helpers
    
    func formProperties() -> TractFormProperties {
        return self.properties as! TractFormProperties
    }
}
