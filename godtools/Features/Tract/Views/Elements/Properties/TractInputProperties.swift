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
    
    @objc var name: String?
    var type: InputType = .text
    @objc var value: String?
    @objc var required: Bool = false
    
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
    
    @objc var width: CGFloat = 300.0
    @objc var height: CGFloat = 44.0
    @objc var xMargin = BaseTractElement.xMargin
    @objc var yMargin = BaseTractElement.yMargin
    @objc var cornerRadius: CGFloat = 5.0
    @objc var borderWidth: CGFloat = 0.6
    @objc var backgroundColor = UIColor.gtWhite
    @objc var color = UIColor.gtBlack
    @objc var font = UIFont.gtRegular(size: 16.0)
    @objc var placeholder: String?

}
