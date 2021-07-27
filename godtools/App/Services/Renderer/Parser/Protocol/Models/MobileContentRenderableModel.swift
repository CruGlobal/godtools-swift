//
//  MobileContentRenderableModel.swift
//  godtools
//
//  Created by Levi Eggert on 7/17/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

protocol MobileContentRenderableModel {
    
    var restrictTo: String? { get }
    var version: String? { get }
    var modelContentIsRenderable: Bool { get }
    var isRenderable: Bool { get }
    
    func getRenderableChildModels() -> [MobileContentRenderableModel]
}

extension MobileContentRenderableModel {
    
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
        
        return modelContentIsRenderable && meetsRestrictToTypeForRendering && meetsVersionRequirementForRendering
    }
    
    // TODO: Should I override this here or force concrete types to provide this or can this be shared between xml nodes and multiplatform. ~Levi
    func getRenderableChildModels() -> [MobileContentRenderableModel] {
        return Array()
    }
}
