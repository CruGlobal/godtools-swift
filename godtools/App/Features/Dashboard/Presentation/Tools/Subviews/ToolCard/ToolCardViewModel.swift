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

class ToolCardViewModel: ObservableObject {
        
    private let localizationServices: LocalizationServices
    private let getLanguageAvailabilityUseCase: GetLanguageAvailabilityUseCase
    private let getToolIsFavoritedUseCase: GetToolIsFavoritedUseCase
    private let attachmentsRepository: AttachmentsRepository
            
    private var getBannerImageCancellable: AnyCancellable?
    private var cancellables = Set<AnyCancellable>()
    
    let tool: ToolDomainModel
    
    @Published var bannerImageData: OptionalImageData?
    @Published var isFavorited = false
    @Published var title: String = ""
    @Published var category: String = ""
    @Published var languageAvailability: String = ""
    @Published var detailsButtonTitle: String = ""
    @Published var openButtonTitle: String = ""
    @Published var layoutDirection: LayoutDirection = .leftToRight
            
    init(tool: ToolDomainModel, localizationServices: LocalizationServices, getLanguageAvailabilityUseCase: GetLanguageAvailabilityUseCase, getToolIsFavoritedUseCase: GetToolIsFavoritedUseCase, attachmentsRepository: AttachmentsRepository) {
        
        self.tool = tool
        self.localizationServices = localizationServices
        self.getLanguageAvailabilityUseCase = getLanguageAvailabilityUseCase
        self.getToolIsFavoritedUseCase = getToolIsFavoritedUseCase
        self.attachmentsRepository = attachmentsRepository
                
        let currentTranslationLanguage: LanguageDomainModel = tool.currentTranslationLanguage
        let localeIdentifier: String = currentTranslationLanguage.localeIdentifier
        
        title = tool.name
        category = localizationServices.stringForLocaleElseSystemElseEnglish(localeIdentifier: localeIdentifier, key: "tool_category_\(tool.category)")
        detailsButtonTitle = localizationServices.stringForLocaleElseSystemElseEnglish(localeIdentifier: localeIdentifier, key: "favorites.favoriteLessons.details")
        openButtonTitle = localizationServices.stringForLocaleElseSystemElseEnglish(localeIdentifier: localeIdentifier, key: "open")
        layoutDirection = LayoutDirection.from(languageDirection: currentTranslationLanguage.direction)
        
        getToolIsFavoritedUseCase.getToolIsFavoritedPublisher(id: tool.id)
            .receive(on: DispatchQueue.main)
            .assign(to: \.isFavorited, on: self)
            .store(in: &cancellables)
        
        downloadBannerImage()
    }
    
    private func downloadBannerImage() {
        
        getBannerImageCancellable = nil
        
        let attachmentId: String = tool.bannerImageId
        
        if let cachedImage = attachmentsRepository.getAttachmentImageFromCache(id: attachmentId) {
            
            bannerImageData = OptionalImageData(image: cachedImage, imageIdForAnimationChange: attachmentId)
        }
        else {
            
            getBannerImageCancellable = attachmentsRepository.getAttachmentImagePublisher(id: attachmentId)
                .receive(on: DispatchQueue.main)
                .sink { [weak self] (image: Image?) in
                    self?.bannerImageData = OptionalImageData(image: image, imageIdForAnimationChange: attachmentId)
                }
        }
    }
}
