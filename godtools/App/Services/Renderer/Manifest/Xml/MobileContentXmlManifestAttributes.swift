//
//  MobileContentXmlManifestAttributes.swift
//  godtools
//
//  Created by Levi Eggert on 10/22/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit
import SWXMLHash

class MobileContentXmlManifestAttributes: MobileContentManifestAttributesType {
        
    private let backgroundColorString: String
    private let navbarColorString: String?
    private let navbarControlColorString: String?
    private let primaryColorString: String
    private let primaryTextColorString: String
    private let textColorString: String
    
    let backgroundImage: String?
    let backgroundImageAlign: [String]
    let backgroundImageScaleType: String
    let categoryLabelColor: String?
    let dismissListeners: [String]
    let locale: String?
    let textScale: String?
    let tool: String?
    let type: String?
    
    required init(manifest: XMLIndexer) {
        
        let attributes: [String: XMLAttribute] = manifest.element?.allAttributes ?? [:]
        
        backgroundColorString = attributes["background-color"]?.text ?? "rgba(255,255,255,1)"
        backgroundImage = attributes["background-image"]?.text
        
        if let backgroundImageAlignValues = attributes["background-image-align"]?.text, !backgroundImageAlignValues.isEmpty {
            backgroundImageAlign = backgroundImageAlignValues.components(separatedBy: " ")
        }
        else {
            backgroundImageAlign = [MobileContentBackgroundImageAlignType.center.rawValue]
        }
        backgroundImageScaleType = attributes["background-image-scale-type"]?.text ?? MobileContentBackgroundImageScaleType.fill.rawValue
        categoryLabelColor = attributes["category-label-color"]?.text
        dismissListeners = attributes["dismiss-listeners"]?.text.components(separatedBy: " ") ?? []
        locale = attributes["locale"]?.text
        navbarColorString = attributes["navbar-color"]?.text
        navbarControlColorString = attributes["navbar-control-color"]?.text
        primaryColorString = attributes["primary-color"]?.text ?? "rgba(59,164,219,1)"
        primaryTextColorString = attributes["primary-text-color"]?.text ?? "rgba(255,255,255,1)"
        textColorString = attributes["text-color"]?.text ?? "rgba(90,90,90,1)"
        textScale = attributes["text-scale"]?.text
        tool = attributes["tool"]?.text
        type = attributes["type"]?.text
    }
    
    var backgroundColor: UIColor {
        return MobileContentRGBAColor(stringColor: backgroundColorString).color
    }
    
    var primaryColor: UIColor {
        return MobileContentRGBAColor(stringColor: primaryColorString).color
    }
    
    var primaryTextColor: UIColor {
        return MobileContentRGBAColor(stringColor: primaryTextColorString).color
    }
    
    var textColor: UIColor {
        return MobileContentRGBAColor(stringColor: textColorString).color
    }
    
    var navbarColor: UIColor? {
        if let navbarColorString = self.navbarColorString {
            return MobileContentRGBAColor(stringColor: navbarColorString).color
        }
        return nil
    }
    
    var navbarControlColor: UIColor? {
        if let navbarControlColorString = self.navbarControlColorString {
            return MobileContentRGBAColor(stringColor: navbarControlColorString).color
        }
        return nil
    }
}
