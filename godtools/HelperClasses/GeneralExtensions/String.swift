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
    
    // TODO: Remove and replace with LocalizationServices. ~Levi
    var localized: String {
        return NSLocalizedString(self, tableName: nil, bundle: Bundle.main, value: "", comment: "")
    }
    
    // TODO: Remove and replace with LocalizationServices. ~Levi
    func localized(default dflt: String) -> String {
        return NSLocalizedString(self, tableName: nil, bundle: Bundle.main, value: dflt, comment: "")
    }
    
    // TODO: Remove and replace with LocalizationServices. ~Levi
    /// returns the translation for self using the given language
    func localized(for languageCode: String?) -> String? {
        // if the language is not given, or corresponding translation bundle not found, use default localization
        guard let languageCode = languageCode,
            let path = Bundle.main.path(forResource: languageCode, ofType: "lproj"),
            let bundle = Bundle(path: path) else {
                return localized
        }
        return bundle.localizedString(forKey: self, value: nil, table: nil)
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
    
    var camelCased: String {
        let items = self.components(separatedBy: "-")
        var camelCase = ""
        items.enumerated().forEach {
            camelCase += 0 == $0 ? $1 : $1.capitalized
        }
        return camelCase
    }
}
