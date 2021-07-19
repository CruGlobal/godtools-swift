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
    private let backgroundImageAlignmentStrings: [String]
    private let backgroundImageScaleString: String?
    private let navbarColorString: String?
    private let navbarControlColorString: String?
    private let primaryColorString: String
    private let primaryTextColorString: String
    private let textColorString: String
    private let textScaleString: String?
    
    let backgroundImage: String?
    let categoryLabelColor: String?
    let dismissListeners: [String]
    let locale: String?
    let tool: String?
    let type: String?
    
    required init(manifest: XMLIndexer) {
        
        let attributes: [String: XMLAttribute] = manifest.element?.allAttributes ?? [:]
        
        backgroundColorString = attributes["background-color"]?.text ?? "rgba(255,255,255,1)"
        backgroundImage = attributes["background-image"]?.text
        backgroundImageAlignmentStrings = attributes["background-image-align"]?.text.components(separatedBy: " ") ?? []
        backgroundImageScaleString = attributes["background-image-scale-type"]?.text
        categoryLabelColor = attributes["category-label-color"]?.text
        dismissListeners = attributes["dismiss-listeners"]?.text.components(separatedBy: " ") ?? []
        locale = attributes["locale"]?.text
        navbarColorString = attributes["navbar-color"]?.text
        navbarControlColorString = attributes["navbar-control-color"]?.text
        primaryColorString = attributes["primary-color"]?.text ?? "rgba(59,164,219,1)"
        primaryTextColorString = attributes["primary-text-color"]?.text ?? "rgba(255,255,255,1)"
        textColorString = attributes["text-color"]?.text ?? "rgba(90,90,90,1)"
        textScaleString = attributes["text-scale"]?.text
        tool = attributes["tool"]?.text
        type = attributes["type"]?.text
    }
    
    var backgroundColor: UIColor {
        return MobileContentRGBAColor(stringColor: backgroundColorString).color
    }
    
    var backgroundImageAlignments: [MobileContentBackgroundImageAlignment] {
        let backgroundImageAlignments: [MobileContentBackgroundImageAlignment] = backgroundImageAlignmentStrings.compactMap({MobileContentBackgroundImageAlignment(rawValue: $0.lowercased())})
        if !backgroundImageAlignments.isEmpty {
            return backgroundImageAlignments
        }
        else {
            return [.center]
        }
    }
    
    var backgroundImageScale: MobileContentBackgroundImageScale {
        let defaultValue: MobileContentBackgroundImageScale = .fill
        guard let backgroundImageScaleString = self.backgroundImageScaleString else {
            return defaultValue
        }
        return MobileContentBackgroundImageScale(rawValue: backgroundImageScaleString) ?? defaultValue
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
    
    var primaryColor: UIColor {
        return MobileContentRGBAColor(stringColor: primaryColorString).color
    }
    
    var primaryTextColor: UIColor {
        return MobileContentRGBAColor(stringColor: primaryTextColorString).color
    }
    
    var textColor: UIColor {
        return MobileContentRGBAColor(stringColor: textColorString).color
    }
    
    var textScale: MobileContentTextScale {
        return MobileContentTextScale(textScaleString: textScaleString)
    }
}
