//
//  ToolCardViewModel.swift
//  godtools
//
//  Created by Rachael Skeath on 4/11/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

@MainActor
class ToolCardViewModel: ObservableObject {
        
    private let getToolIsFavoritedUseCase: GetToolIsFavoritedUseCase
    
    private var cancellables: Set<AnyCancellable> = Set()

    let tool: ToolListItemDomainModelInterface
    let accessibilityWithToolName: String
    
    @Published private(set) var banner: OptionalImageData?
    @Published private(set) var isFavorited = false
    @Published private(set) var name: String = ""
    @Published private(set) var category: String = ""
    @Published private(set) var languageAvailability: String?
    @Published private(set) var detailsButtonTitle: String = ""
    @Published private(set) var openButtonTitle: String = ""
            
    init(
        tool: ToolListItemDomainModelInterface,
        accessibility: AccessibilityStrings.Button,
        getToolIsFavoritedUseCase: GetToolIsFavoritedUseCase,
        getToolBannerUseCase: GetToolBannerUseCase,
        imageCache: ImageCacheInterface
    ) {
        
        self.tool = tool
        self.getToolIsFavoritedUseCase = getToolIsFavoritedUseCase
                        
        name = tool.name
        category = tool.category
        languageAvailability = tool.languageAvailability?.availabilityString
        isFavorited = tool.isFavorited
        openButtonTitle = tool.strings.openToolActionTitle
        detailsButtonTitle = tool.strings.openToolDetailsActionTitle
        
        accessibilityWithToolName = AccessibilityStrings.Button.getToolButtonAccessibility(
            toolButton: accessibility,
            toolName: tool.name
        )
            
        getToolIsFavoritedUseCase
            .execute(
                toolId: tool.dataModelId
            )
            .map { $0.isFavorited }
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in
                
            }, receiveValue: { [weak self] (isFavorited: Bool) in
                self?.isFavorited = isFavorited
            })
            .store(in: &cancellables)
        
        let attachmentId: String = tool.bannerImageId
        
        loadBanner(
            getToolBannerUseCase: getToolBannerUseCase,
            imageCache: imageCache,
            attachmentId: attachmentId
        )
    }
    
    private func loadBanner(
        getToolBannerUseCase: GetToolBannerUseCase,
        imageCache: ImageCacheInterface,
        attachmentId: String
    ) {
        
        if let cachedImage = imageCache.getImage(id: attachmentId) {
            
            banner = getBanner(image: cachedImage, attachmentId: attachmentId)
            
            return
        }
        
        Task { [weak self] in
            
            let imageData = try await getToolBannerUseCase
                .execute(
                    attachmentId: attachmentId
                )
            
            let image: Image? = imageData?.toImage()
            
            if let image = image {
                imageCache.cacheImage(id: attachmentId, image: image)
            }
            
            self?.banner = self?.getBanner(image: image, attachmentId: attachmentId)
        }
    }
    
    private func getBanner(image: Image?, attachmentId: String) -> OptionalImageData {
        return OptionalImageData(image: image, imageIdForAnimationChange: attachmentId)
    }
}
