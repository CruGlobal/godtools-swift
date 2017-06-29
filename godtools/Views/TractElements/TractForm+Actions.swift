//
//  TractForm+Actions.swift
//  godtools
//
//  Created by Pablo Marti on 6/7/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation
import UIKit

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
    
    func getFormData() -> [String: String] {
        var data = [String: String]()
        
        for element in self.formElements {
            if element.formName() != "" {
                data[element.formName()] = element.formValue()
            }
        }
        
        return data
    }
    
    func validateForm() -> Bool {
        var validationErrors = [String]()
        
        for element in formElements {
            let input = element as! TractInput
            let inputProperties = input.properties as! TractInputProperties
            let trimmedInputText = input.textField.text?.trimmingCharacters(in: .whitespaces)
            if inputProperties.required && trimmedInputText?.characters.count == 0 {
                let fieldName = inputProperties.name ?? ""
                validationErrors.append(String(format: "required_field_missing".localized, fieldName.localizedCapitalized))
            }
        }
        
        if validationErrors.count == 0 {
            return true
        }
 
        showAlert(validationErrors)
        return false
    }
    
    private func showAlert(_ validationErrors: [String]) {
        let alert = UIAlertController(title: "error".localized,
                                      message: validationErrors.joined(separator: "\n"),
                                      preferredStyle: .alert)
        
        weak var weakAlert = alert
        
        alert.addAction(UIAlertAction(title: "ok".localized,
                                      style: .default,
                                      handler: { (action) in
                                        weakAlert?.dismiss(animated: true, completion: nil)
        }))
        
        getDelegate()?.showAlert(alert)
    }
}
