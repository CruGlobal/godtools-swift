
//
//  ContentParagraphNode.swift
//  godtools
//
//  Created by Levi Eggert on 10/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//
import Foundation
import SWXMLHash

class ContentParagraphNode: MobileContentXmlNode, ContentParagraphModelType {
        
    required init(xmlElement: XMLElement) {
        
        super.init(xmlElement: xmlElement)
    }
    
    func watchVisibility(rendererState: MobileContentMultiplatformState, visibilityChanged: @escaping ((MobileContentVisibility) -> Void)) -> MobileContentFlowWatcherType {
        fatalError("Xml rendering no longer supported. Using multiplatform parser.")
    }
}
