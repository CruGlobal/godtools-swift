//
//  ContentVideoModelType.swift
//  godtools
//
//  Created by Levi Eggert on 7/14/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

protocol ContentVideoModelType: MobileContentRenderableModel {
    
    var provider: MobileContentVideoProvider { get }
    var videoId: String? { get }
}

extension ContentVideoModelType {
    
    var modelContentIsRenderable: Bool {
        
        guard let videoId = self.videoId else {
            return false
        }
        
        guard !videoId.isEmpty else {
            return false
        }
        
        return true
    }
}
