//
//  String.swift
//  godtools
//
//  Created by Devserker on 4/24/17.
//  Copyright © 2017 Cru. All rights reserved.
//


import Foundation
import CommonCrypto
import UIKit

extension String {
    
    static var godtoolsRGBANumberFormatter: NumberFormatter?
    
    var localized: String {
        return NSLocalizedString(self, tableName: nil, bundle: Bundle.main, value: "", comment: "")
    }
    func localized(default dflt: String) -> String {
        return NSLocalizedString(self, tableName: nil, bundle: Bundle.main, value: dflt, comment: "")
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
            values.append(CGFloat(truncating: value!))
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
    
    
    func deletePrefix(_ prefix: String) -> String {
        guard self.hasPrefix(prefix) else { return self }
        return String(self.dropFirst(prefix.count))
    }
    
    
    var md5: String! {
        let str = self.cString(using: String.Encoding.utf8)
        let strLen = CC_LONG(self.lengthOfBytes(using: String.Encoding.utf8))
        let digestLen = Int(CC_MD5_DIGEST_LENGTH)
        let result = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: digestLen)
        
        CC_MD5(str!, strLen, result)
        
        var hash = String()
        for i in 0..<digestLen {
            hash += String(format: "%02x", result[i])
        }
        result.deallocate()
        
        return hash
    }
    
}
