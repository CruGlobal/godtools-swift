//
//  TractFormActions.swift
//  godtools
//
//  Created by Pablo Marti on 6/7/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation

extension TractForm {
    
    override func receiveMessage() {
        if self.properties.action == nil {
            return
        }
        
        let manager: TractFormManager = TractFormManager()
        let params = getFormData()
        
        let _ = manager.postFromForm(path: self.properties.action!, params: params)
    }
    
    func attachElementToForm(element: BaseTractElement) {
        formElements.append(element)
    }
    
    func getFormData() -> [String: String] {
        var data = [String: String]()
        
        for element in self.formElements {
            if element.formName() != "" {
                data[element.formName()] = element.formValue()
            }
        }
        
        return data
    }
    
}
