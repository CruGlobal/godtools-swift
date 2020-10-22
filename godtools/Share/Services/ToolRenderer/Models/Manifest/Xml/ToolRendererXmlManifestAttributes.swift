//
//  ToolRendererXmlManifestAttributes.swift
//  godtools
//
//  Created by Levi Eggert on 10/22/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import SWXMLHash

struct ToolRendererXmlManifestAttributes: ToolRendererManifestAttributesType {
    
    let backgroundColor: String
    let backgroundImage: String?
    let backgroundImageAlign: String?
    let backgroundImageScaleType: String?
    let categoryLabelColor: String
    let locale: String?
    let navbarColor: String?
    let navbarControlColor: String?
    let primaryColor: String
    let primaryTextColor: String
    let textColor: String?
    let tool: String?
    let type: String?
    
    init(manifest: XMLIndexer) {
        
        let attributes: [String: XMLAttribute]? = manifest.element?.allAttributes
        
        backgroundColor = attributes?["background-color"]?.text ?? ""
        backgroundImage = attributes?["background-image"]?.text
        backgroundImageAlign = attributes?["background-image-align"]?.text
        backgroundImageScaleType = attributes?["background-image-scale-type"]?.text
        categoryLabelColor = attributes?["category-label-color"]?.text ?? ""
        locale = attributes?["locale"]?.text
        navbarColor = attributes?["navbar-color"]?.text
        navbarControlColor = attributes?["navbar-control-color"]?.text
        primaryColor = attributes?["primary-color"]?.text ?? ""
        primaryTextColor = attributes?["primary-text-color"]?.text ?? ""
        textColor = attributes?["text-color"]?.text
        tool = attributes?["tool"]?.text
        type = attributes?["type"]?.text
    }
}
