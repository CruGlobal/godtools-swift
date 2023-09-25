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
        
    private let getLanguageAvailabilityUseCase: GetLanguageAvailabilityUseCase
    private let getToolIsFavoritedUseCase: GetToolIsFavoritedUseCase
    private let getInterfaceStringUseCase: GetInterfaceStringUseCase
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
            
    init(tool: ToolDomainModel, alternateLanguage: LanguageDomainModel? = nil, getLanguageAvailabilityUseCase: GetLanguageAvailabilityUseCase, getToolIsFavoritedUseCase: GetToolIsFavoritedUseCase, getInterfaceStringUseCase: GetInterfaceStringUseCase, attachmentsRepository: AttachmentsRepository) {
        
        self.tool = tool
        self.getLanguageAvailabilityUseCase = getLanguageAvailabilityUseCase
        self.getToolIsFavoritedUseCase = getToolIsFavoritedUseCase
        self.getInterfaceStringUseCase = getInterfaceStringUseCase
        self.attachmentsRepository = attachmentsRepository
                
        let currentTranslationLanguage: LanguageDomainModel = tool.currentTranslationLanguage
        
        title = tool.name
        
        category = getInterfaceStringUseCase.getString(id: "tool_category_\(tool.category)")
        detailsButtonTitle = getInterfaceStringUseCase.getString(id: "favorites.favoriteLessons.details")
        openButtonTitle = getInterfaceStringUseCase.getString(id: "open")
        
        layoutDirection = LayoutDirection.from(languageDirection: currentTranslationLanguage.direction)
        
        getToolIsFavoritedUseCase.getToolIsFavoritedPublisher(id: tool.id)
            .receive(on: DispatchQueue.main)
            .assign(to: \.isFavorited, on: self)
            .store(in: &cancellables)
        
        downloadBannerImage()
        setLanguageAvailabilityText(language: alternateLanguage)
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
    
    private func setLanguageAvailabilityText(language: LanguageDomainModel?) {
        
        let getLanguageAvailability = getLanguageAvailabilityUseCase.getLanguageAvailability(for: tool, language: language)
        
        if getLanguageAvailability.isAvailable {
            
            languageAvailability = getLanguageAvailability.availabilityString
            
        } else {
            languageAvailability = ""
        }
    }
}
