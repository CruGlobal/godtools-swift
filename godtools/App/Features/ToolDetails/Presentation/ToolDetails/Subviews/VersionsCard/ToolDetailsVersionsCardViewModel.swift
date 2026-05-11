//
//  ToolDetailsVersionsCardViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 6/24/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import SwiftUI
import Combine
import RequestOperation

@MainActor
class ToolDetailsVersionsCardViewModel: ObservableObject {
    
    private let toolVersion: ToolVersionDomainModel
    
    private var getBannerImageTask: Task<Void, Error>?
        
    let isSelected: Bool
    let name: String
    let description: String
    let languages: String
    let toolLanguageName: String?
    let toolLanguageNameIsSupported: Bool
    let toolParallelLanguageName: String?
    let toolParallelLanguageNameIsSupported: Bool?
    
    @Published private(set) var banner: OptionalImageData?
    
    init(toolVersion: ToolVersionDomainModel, getToolBannerUseCase: GetToolBannerUseCase, isSelected: Bool) {
        
        self.toolVersion = toolVersion
        self.isSelected = isSelected
        
        name = toolVersion.name
        description = toolVersion.description
        languages = toolVersion.numberOfLanguages
        toolLanguageName = toolVersion.toolLanguageName
        toolLanguageNameIsSupported = toolVersion.toolLanguageNameIsSupported
        toolParallelLanguageName = toolVersion.toolParallelLanguageName
        toolParallelLanguageNameIsSupported = toolVersion.toolParallelLanguageNameIsSupported
        
        let attachmentId: String = toolVersion.bannerImageId
        
        getBannerImageTask = Task {
            
            let image = try await getToolBannerUseCase
                .execute(
                    attachmentId: attachmentId
                )
            
            banner = OptionalImageData(image: image, imageIdForAnimationChange: attachmentId)
        }
    }
    
    deinit {
        getBannerImageTask?.cancel()
    }
}
