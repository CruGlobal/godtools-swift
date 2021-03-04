//
//  MobileContentXmlManifestAttributes.swift
//  godtools
//
//  Created by Levi Eggert on 10/22/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import SWXMLHash

struct MobileContentXmlManifestAttributes: MobileContentManifestAttributesType {
        
    let backgroundColor: String
    let backgroundImage: String?
    let backgroundImageAlign: [String]
    let backgroundImageScaleType: String
    let categoryLabelColor: String?
    let locale: String?
    let navbarColor: String?
    let navbarControlColor: String?
    let primaryColor: String
    let primaryTextColor: String
    let textColor: String
    let tool: String?
    let type: String?
    
    init(manifest: XMLIndexer) {
        
        let attributes: [String: XMLAttribute] = manifest.element?.allAttributes ?? [:]
        
        backgroundColor = attributes["background-color"]?.text ?? "rgba(255,255,255,1)"
        backgroundImage = attributes["background-image"]?.text
        
        if let backgroundImageAlignValues = attributes["background-image-align"]?.text, !backgroundImageAlignValues.isEmpty {
            backgroundImageAlign = backgroundImageAlignValues.components(separatedBy: " ")
        }
        else {
            backgroundImageAlign = [MobileContentBackgroundImageAlignType.center.rawValue]
        }
        backgroundImageScaleType = attributes["background-image-scale-type"]?.text ?? MobileContentBackgroundImageScaleType.fill.rawValue
        categoryLabelColor = attributes["category-label-color"]?.text
        locale = attributes["locale"]?.text
        navbarColor = attributes["navbar-color"]?.text
        navbarControlColor = attributes["navbar-control-color"]?.text
        primaryColor = attributes["primary-color"]?.text ?? "rgba(59,164,219,1)"
        primaryTextColor = attributes["primary-text-color"]?.text ?? "rgba(255,255,255,1)"
        textColor = attributes["text-color"]?.text ?? "rgba(90,90,90,1)"
        tool = attributes["tool"]?.text
        type = attributes["type"]?.text
    }
    
    func getBackgroundColor() -> MobileContentRGBAColor {
        return MobileContentRGBAColor(stringColor: backgroundColor)
    }
    
    func getNavBarColor() -> MobileContentRGBAColor? {
        if let navBarColor = self.navbarColor {
            return MobileContentRGBAColor(stringColor: navBarColor)
        }
        return nil
    }
    
    func getNavBarControlColor() -> MobileContentRGBAColor? {
        if let navbarControlColor = self.navbarControlColor {
            return MobileContentRGBAColor(stringColor: navbarControlColor)
        }
        return nil
    }
    
    func getPrimaryColor() -> MobileContentRGBAColor {
        return MobileContentRGBAColor(stringColor: primaryColor)
    }
    
    func getPrimaryTextColor() -> MobileContentRGBAColor {
        return MobileContentRGBAColor(stringColor: primaryTextColor)
    }
    
    func getTextColor() -> MobileContentRGBAColor {
        return MobileContentRGBAColor(stringColor: textColor)
    }
}
