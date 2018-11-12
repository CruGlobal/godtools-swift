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
    
    static var godtoolsRGBANumberFormatter: NumberFormatter?
    
    var localized: String {
        return NSLocalizedString(self, tableName: nil, bundle: Bundle.main, value: "", comment: "")
    }
    
    func removeBreaklines() -> String {
        let regex = try! NSRegularExpression(pattern: "\n", options: .caseInsensitive)
        let range = NSMakeRange(0, self.count)
        return regex.stringByReplacingMatches(in: self, options: [], range: range, withTemplate: "")
    }
    
    func condenseWhitespaces() -> String {
        let components = self.components(separatedBy: .whitespacesAndNewlines)
        return components.filter { !$0.isEmpty }.joined(separator: " ")
    }
    
    func getRGBAColor() -> UIColor {
        if String.godtoolsRGBANumberFormatter == nil {
            initializeGodToolsRGBANumberFormatter()
        }
        
        let components = self.components(separatedBy: ",")
        var values = [CGFloat]()
        
        for component in components {
            let result = String(component.filter {
                String($0).rangeOfCharacter(from: CharacterSet(charactersIn: ".0123456789")) != nil
            })

            
            let value = String.godtoolsRGBANumberFormatter!.number(from: result)
            values.append(CGFloat(value!))
        }
        
        return UIColor(red: values[0]/255.0, green: values[1]/255.0, blue: values[2]/255.0, alpha: values[3])
    }
    
    private func initializeGodToolsRGBANumberFormatter() {
        String.godtoolsRGBANumberFormatter = NumberFormatter()
        String.godtoolsRGBANumberFormatter!.decimalSeparator = "."
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
    
    var dashCased: String? {
        let pattern = "([a-z0-9])([A-Z])"
        
        let regex = try? NSRegularExpression(pattern: pattern, options: [])
        let range = NSRange(location: 0, length: self.count)
        return regex?.stringByReplacingMatches(in: self, options: [], range: range, withTemplate: "$1-$2").lowercased()
    }
    
    var camelCased: String {
        let items = self.components(separatedBy: "-")
        var camelCase = ""
        items.enumerated().forEach {
            camelCase += 0 == $0 ? $1 : $1.capitalized
        }
        return camelCase
    }
    
}
