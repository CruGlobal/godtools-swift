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
    let isSelected: Bool
    let name: String
    let description: String
    let languages: String
    let primaryLanguageName: String?
    let primaryLanguageIsSupported: Bool
    let parallelLanguageName: String?
    let parallelLanguageIsSupported: Bool
    
    init(toolVersion: ToolVersionDomainModel, bannerImageRepository: ResourceBannerImageRepository, isSelected: Bool) {
        
        self.bannerImageRepository = bannerImageRepository
        
        bannerImage = bannerImageRepository.getBannerImage(resourceId: toolVersion.id, bannerId: toolVersion.bannerImageId)
        self.isSelected = isSelected
        name = toolVersion.name
        description = toolVersion.description
        languages = toolVersion.languages
        primaryLanguageName = toolVersion.primaryLanguage
        primaryLanguageIsSupported = toolVersion.primaryLanguageIsSupported
        parallelLanguageName = toolVersion.parallelLanguage
        parallelLanguageIsSupported = toolVersion.parallelLanguageIsSupported
    }
}
