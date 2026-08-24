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
            
    let isSelected: Bool
    let name: String
    let description: String
    let languages: String
    let toolLanguageName: String?
    let toolLanguageNameIsSupported: Bool
    let toolParallelLanguageName: String?
    let toolParallelLanguageNameIsSupported: Bool?
    
    @Published private(set) var banner: OptionalImageData?
    
    init(
        toolVersion: ToolVersionDomainModel,
        getToolBannerUseCase: GetToolBannerUseCase,
        dataCache: DataCacheInterface,
        isSelected: Bool
    ) {
        
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
        
        loadBanner(
            getToolBannerUseCase: getToolBannerUseCase,
            dataCache: dataCache,
            attachmentId: attachmentId
        )
    }
    
    private func loadBanner(
        getToolBannerUseCase: GetToolBannerUseCase,
        dataCache: DataCacheInterface,
        attachmentId: String
    ) {
        
        if let cachedImage = dataCache.getData(id: attachmentId)?.toImage() {
            
            banner = getBanner(image: cachedImage, attachmentId: attachmentId)
            
            return
        }
        
        Task { [weak self] in
            
            let imageData = try await getToolBannerUseCase
                .execute(
                    attachmentId: attachmentId
                )
            
            if let imageData = imageData {
                dataCache.cacheData(id: attachmentId, data: imageData)
            }
            
            self?.banner = self?.getBanner(image: imageData?.toImage(), attachmentId: attachmentId)
        }
    }
    
    private func getBanner(image: Image?, attachmentId: String) -> OptionalImageData {
        return OptionalImageData(image: image, imageIdForAnimationChange: attachmentId)
    }
}
