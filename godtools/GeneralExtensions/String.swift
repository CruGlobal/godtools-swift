//
//  String.swift
//  godtools
//
//  Created by Devserker on 4/24/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation
import UIKit

extension String {
    
    var localized: String {
        return NSLocalizedString(self, tableName: nil, bundle: Bundle.main, value: "", comment: "")
    }
    
    func condenseWhitespace() -> String {
        let components = self.components(separatedBy: NSCharacterSet.whitespacesAndNewlines)
        return components.filter { !$0.isEmpty }.joined(separator: " ")
    }
    
    func getRGBAColor() -> UIColor {
        let components = self.components(separatedBy: ",")
        var values = [CGFloat]()
        
        for component in components {
            let result = String(component.characters.filter {
                String($0).rangeOfCharacter(from: CharacterSet(charactersIn: ".0123456789")) != nil
            })
            let value = NumberFormatter().number(from: result)
            values.append(CGFloat(value!))
        }
        
        return UIColor(red: values[0]/255.0, green: values[1]/255.0, blue: values[2]/255.0, alpha: values[3])
    }
    
    func transformToNumber() -> Int {
        let data = self.data(using: .utf8)!
        var finalValue = 0
        
        for item in data {
            let hexString = String(format:"%02x", item)
            let scanner = Scanner(string: hexString)
            var value: UInt64 = 0
            scanner.scanHexInt64(&value)
            
            finalValue += Int(value)
        }
        
        return finalValue
    }
    
}
