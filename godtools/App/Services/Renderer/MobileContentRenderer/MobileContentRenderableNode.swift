//
//  MobileContentRenderableNode.swift
//  godtools
//
//  Created by Levi Eggert on 1/22/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation
import SWXMLHash

protocol MobileContentRenderableNode {
    
    var xmlElement: XMLElement { get }
}

extension MobileContentRenderableNode {
    
    private var attributes: [String: XMLAttribute] {
        return xmlElement.allAttributes
    }
    
    private var restrictTo: String? {
        return attributes["restrictTo"]?.text
    }
    
    private var version: String? {
        return attributes["version"]?.text
    }
    
    private var meetsRestrictToTypeForRendering: Bool {
        
        if let restrictToString = self.restrictTo, let restrictToType = MobileContentRestrictToType(rawValue: restrictToString) {
            
            return restrictToType == .iOS || restrictToType == .mobile
        }
        
        return true
    }
    
    private var meetsVersionRequirementForRendering: Bool {
        
        if let versionString = self.version, let versionNumber = Int(versionString) {
            
            return versionNumber <= MobileContentRendererVersion.versionNumber
        }
        
        return true
    }
    
    var isRenderable: Bool {
        
        return meetsRestrictToTypeForRendering && meetsVersionRequirementForRendering
    }
}
