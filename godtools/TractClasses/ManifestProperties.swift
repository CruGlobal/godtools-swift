//
//  ManifestProperties.swift
//  godtools
//
//  Created by Pablo Marti on 6/9/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import UIKit

class ManifestProperties: TractProperties {
    
    var backgroundColor = GTAppDefaultStyle.backgroundColorString.getRGBAColor()
    var backgroundImage: String = ""
    var backgroundImageAlign: [TractImageConfig.ImageAlign] = [.center]
    var backgroundImageScaleType: TractImageConfig.ImageScaleType = .fill
    var navBarColor = GTAppDefaultStyle.navBarColor.getRGBAColor()
    var navBarControlColor = GTAppDefaultStyle.navBarControlColor.getRGBAColor()
    var resources = [String: String]()
    
    override func defineProperties() {
        self.properties = ["backgroundColor", "backgroundImage", "navBarColor",
                           "navBarControlColor"]
    }
    
    override func customProperties() -> [String]? {
        return ["backgroundImageAlign", "backgroundImageScaleType"]
    }
    
    override func performCustomProperty(propertyName: String, value: String) {
        switch propertyName {
        case "backgroundImageAlign":
            setupImageAligns(kind: value)
        case "backgroundImageScaleType":
            setupImageScaleType(kind: value)
        case "resources":
            setupImageScaleType(kind: value)
        default: break
        }
    }
    
    func setupImageAligns(kind: String) {
        var items: [TractImageConfig.ImageAlign] = []
        
        for value in kind.components(separatedBy: " ") {
            items.append(TractImageConfig.getImageAlignKind(string: value))
        }
        
        self.backgroundImageAlign = items
    }
    
    func setupImageScaleType(kind: String) {
        self.backgroundImageScaleType = TractImageConfig.getImageScaleType(string: kind)
    }
    
    func getResourceForFile(filename: String) -> String {
        guard let image = self.resources[filename] else {
            return ""
        }
        return image
    }
    
}
