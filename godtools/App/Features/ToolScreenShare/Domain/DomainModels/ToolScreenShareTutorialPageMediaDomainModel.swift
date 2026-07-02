//
//  ToolScreenShareTutorialPageMediaDomainModel.swift
//  godtools
//
//  Created by Levi Eggert on 11/6/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

enum ToolScreenShareTutorialPageMediaDomainModel: Sendable {
    
    case animation(animatedResource: AnimatedResource)
    case image(name: String)
    case noMedia
}
