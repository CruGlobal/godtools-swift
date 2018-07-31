//
//  TractInputProperties.swift
//  godtools
//
//  Created by Pablo Marti on 6/12/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import UIKit

class TractInputProperties: TractProperties {
    
    enum InputType {
        case text, email, phone, hidden
    }
    
    // MARK: - XML Properties
    
    var name: String?
    var type: InputType = .text
    var value: String?
    var required: Bool = false
    
    override func defineProperties() {
        self.properties = ["name", "value", "required"]
    }
    
    override func customProperties() -> [String]? {
        return ["type"]
    }
    
    override func performCustomProperty(propertyName: String, value: String) {
        switch propertyName {
        case "type":
            setupType(value)
        default: break
        }
    }
    
    private func setupType(_ type: String) {
        switch type {
        case "text":
            self.type = .text
        case "email":
            self.type = .email
        case "phone":
            self.type = .phone
        case "hidden":
            self.type = .hidden
        default: break
        }
    }
    
    func inputValue() -> String {
        return self.value?.removeBreaklines().condenseWhitespaces() ?? ""
    }
    
    // MARK: - View Properties
    
    var width: CGFloat = 300.0
    var height: CGFloat = 44.0
    var xMargin = BaseTractElement.xMargin
    var yMargin = BaseTractElement.yMargin
    var cornerRadius: CGFloat = 5.0
    var borderWidth: CGFloat = 0.6
    var backgroundColor = UIColor.gtWhite
    var color = UIColor.gtBlack
    var font = (AppDelegate.thisDevice == .phone) ? UIFont.gtRegular(size: 16.0) : UIFont.gtRegular(size: 21.0)
    var placeholder: String?

}
