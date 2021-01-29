
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
    
    var nodeContentIsRenderable: Bool { get }
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
        
        if let restrictToString = self.restrictTo, !restrictToString.isEmpty {
            
            let restrictToComponents: [String] = restrictToString.components(separatedBy: " ")
            let restrictToTypes: [MobileContentRestrictToType] = restrictToComponents.compactMap({MobileContentRestrictToType(rawValue: $0)})
                    
            return restrictToTypes.contains(.mobile) || restrictToTypes.contains(.iOS)
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
        
        return nodeContentIsRenderable && meetsRestrictToTypeForRendering && meetsVersionRequirementForRendering
    }
}
