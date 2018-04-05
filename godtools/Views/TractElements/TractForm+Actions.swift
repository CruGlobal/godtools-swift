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
        
        data["language_id"] = getDelegate()?.displayedLanguage()?.remoteId
        
        return data
    }
    
    func validateForm() -> Bool {
        var validationErrors = [String]()
        
        for element in formElements {
            if !element.isKind(of: TractInput.self) {
                continue
            }
            
            let input = element as! TractInput
            let inputProperties = input.properties as! TractInputProperties
            let trimmedInputText = input.textField.text?.trimmingCharacters(in: .whitespaces)
            let fieldName = nameForInput(input, properties: inputProperties)
            
            if inputProperties.required && trimmedInputText?.characters.count == 0 {
                validationErrors.append(String(format: "required_field_missing".localized,
                                               fieldName.localizedCapitalized))
            }
        }
        
        if validationErrors.count == 0 {
            return true
        }
 
        showAlert(validationErrors)
        return false
    }
    
    private func nameForInput(_ input: TractInput, properties: TractInputProperties) -> String {
        let inputName = properties.name ?? ""
        
        guard let elements = input.elements else {
            return inputName
        }
        
        for element in elements {
            if element is TractLabel {
                let textNode = element.elements?.first as? TractTextContent
                let properties = textNode?.textProperties()
                return properties?.value ?? inputName
            }
        }
        
        return inputName
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
