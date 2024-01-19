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
    private let getInterfaceStringInAppLanguageUseCase: GetInterfaceStringInAppLanguageUseCase
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
            
    init(tool: ToolDomainModel, alternateLanguage: LanguageDomainModel? = nil, getLanguageAvailabilityUseCase: GetLanguageAvailabilityUseCase, getToolIsFavoritedUseCase: GetToolIsFavoritedUseCase, getInterfaceStringInAppLanguageUseCase: GetInterfaceStringInAppLanguageUseCase, attachmentsRepository: AttachmentsRepository) {
        
        self.tool = tool
        self.getLanguageAvailabilityUseCase = getLanguageAvailabilityUseCase
        self.getToolIsFavoritedUseCase = getToolIsFavoritedUseCase
        self.getInterfaceStringInAppLanguageUseCase = getInterfaceStringInAppLanguageUseCase
        self.attachmentsRepository = attachmentsRepository
                        
        title = tool.name
        
        getInterfaceStringInAppLanguageUseCase.getStringPublisher(id: "tool_category_\(tool.category)")
            .receive(on: DispatchQueue.main)
            .assign(to: &$category)
        
        getInterfaceStringInAppLanguageUseCase.getStringPublisher(id: "favorites.favoriteLessons.details")
            .receive(on: DispatchQueue.main)
            .assign(to: &$detailsButtonTitle)
        
        getInterfaceStringInAppLanguageUseCase.getStringPublisher(id: "open")
            .receive(on: DispatchQueue.main)
            .assign(to: &$openButtonTitle)
                
        getToolIsFavoritedUseCase.getToolIsFavoritedPublisher(id: tool.id)
            .receive(on: DispatchQueue.main)
            .assign(to: &$isFavorited)
        
        downloadBannerImage()
        setLanguageAvailabilityText(language: alternateLanguage)
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
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
