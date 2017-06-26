//
//  TractForm+Actions.swift
//  godtools
//
//  Created by Pablo Marti on 6/7/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation

extension TractForm {
    
    override func receiveMessage() { }
    
    func attachElementToForm(element: BaseTractElement) {
        self.formElements.append(element)
    }
    
    func getFollowingInputForInput(element: TractInput) -> TractInput? {
        var elementFound = false
        for item in self.formElements {
            if elementFound == false && item == element {
                elementFound = true
                continue
            }
            
            if elementFound == true {
                if item.isKind(of: TractInput.self) {
                    return item as? TractInput
                }
            }
        }
        return nil
    }
    
    override func getFormData() -> [String: String] {
        var data = [String: String]()
        
        for element in self.formElements {
            if element.formName() != "" {
                data[element.formName()] = element.formValue()
            }
        }
        
        return data
    }
    
}
