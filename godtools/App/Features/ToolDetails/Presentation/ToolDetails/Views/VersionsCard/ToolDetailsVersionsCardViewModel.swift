//
//  ToolDetailsVersionsCardViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 6/24/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import SwiftUI

class ToolDetailsVersionsCardViewModel: ObservableObject {
    
    private let bannerImageRepository: ResourceBannerImageRepository
    
    let bannerImage: Image?
    let name: String
    let description: String
    let languages: String
    
    init(toolVersion: ToolVersion, bannerImageRepository: ResourceBannerImageRepository) {
        
        self.bannerImageRepository = bannerImageRepository
        
        bannerImage = bannerImageRepository.getBannerImage(resourceId: toolVersion.id, bannerId: toolVersion.bannerImageId)
        name = toolVersion.name
        description = toolVersion.description
        languages = toolVersion.languages
    }
}
