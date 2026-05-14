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
    
    init(toolVersion: ToolVersionDomainModel, getToolBannerUseCase: GetToolBannerUseCase, inMemoryDataCache: InMemoryDataCache, isSelected: Bool) {
        
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
        
        if let imageData = inMemoryDataCache.getData(id: attachmentId), let image = imageData.toImage() {
            
            banner = getBanner(image: image, attachmentId: attachmentId)
        }
        else {
            
            getBannerImageTask = Task {
                
                let imageData = try await getToolBannerUseCase
                    .execute(
                        attachmentId: attachmentId
                    )
                
                if let imageData = imageData {
                    inMemoryDataCache.cacheData(id: attachmentId, data: imageData)
                }
                
                banner = getBanner(image: imageData?.toImage(), attachmentId: attachmentId)
            }
        }
    }
    
    deinit {
        getBannerImageTask?.cancel()
    }
    
    private func getBanner(image: Image?, attachmentId: String) -> OptionalImageData {
        return OptionalImageData(image: image, imageIdForAnimationChange: attachmentId)
    }
}
