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

protocol ToolCardViewModelDelegate: AnyObject {
    func toolCardTapped(_ tool: ToolDomainModel)
    func toolFavoriteButtonTapped(_ tool: ToolDomainModel)
    func toolDetailsButtonTapped(_ tool: ToolDomainModel)
    func openToolButtonTapped(_ tool: ToolDomainModel)
}

class ToolCardViewModel: BaseToolCardViewModel {
    
    // MARK: - Properties
    
    let tool: ToolDomainModel
    private let localizationServices: LocalizationServices
    
    private let getBannerImageUseCase: GetBannerImageUseCase
    private let getLanguageAvailabilityUseCase: GetLanguageAvailabilityUseCase
    private let getSettingsParallelLanguageUseCase: GetSettingsParallelLanguageUseCase
    private let getToolIsFavoritedUseCase: GetToolIsFavoritedUseCase
    
    private weak var delegate: ToolCardViewModelDelegate?
        
    private var cancellables = Set<AnyCancellable>()
        
    // MARK: - Init
    
    init(tool: ToolDomainModel, localizationServices: LocalizationServices, getBannerImageUseCase: GetBannerImageUseCase, getLanguageAvailabilityUseCase: GetLanguageAvailabilityUseCase, getSettingsParallelLanguageUseCase: GetSettingsParallelLanguageUseCase, getToolIsFavoritedUseCase: GetToolIsFavoritedUseCase, delegate: ToolCardViewModelDelegate?) {
        
        self.tool = tool
        self.localizationServices = localizationServices
        
        self.getBannerImageUseCase = getBannerImageUseCase
        self.getLanguageAvailabilityUseCase = getLanguageAvailabilityUseCase
        self.getSettingsParallelLanguageUseCase = getSettingsParallelLanguageUseCase
        self.getToolIsFavoritedUseCase = getToolIsFavoritedUseCase
        
        self.delegate = delegate
              
        super.init()
        
        setup()
    }
    
    // MARK: - Overrides
 
    override func favoriteToolButtonTapped() {
        delegate?.toolFavoriteButtonTapped(tool)
    }
    
    override func toolCardTapped() {
        delegate?.toolCardTapped(tool)
    }

    override func toolDetailsButtonTapped() {
        delegate?.toolDetailsButtonTapped(tool)
    }
    
    override func openToolButtonTapped() {
        delegate?.openToolButtonTapped(tool)
    }
}

// MARK: - Private

extension ToolCardViewModel {
    
    private func setup() {
        setStrings()
        setupBinding()
    }
    
    private func setupBinding() {
        
        getBannerImageUseCase.getBannerImagePublisher(for: tool.bannerImageId)
            .receive(on: DispatchQueue.main)            
            .assign(to: \.bannerImage, on: self)
            .store(in: &cancellables)
        
        getSettingsParallelLanguageUseCase.getParallelLanguagePublisher()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] parallelLanguage in
                self?.reloadParallelLanguageName(parallelLanguage)
            }
            .store(in: &cancellables)
        
        getToolIsFavoritedUseCase.getToolIsFavoritedPublisher(toolId: tool.id)
            .receive(on: DispatchQueue.main)
            .assign(to: \.isFavorited, on: self)
            .store(in: &cancellables)
    }
        
    private func setStrings() {
        
        title = tool.name
        
        let currentTranslationLanguage: LanguageDomainModel = tool.currentTranslationLanguage
        let localeIdentifier: String = currentTranslationLanguage.localeIdentifier
        
        category = localizationServices.stringForLocaleElseSystem(localeIdentifier: localeIdentifier, key: "tool_category_\(tool.category)")
        detailsButtonTitle = localizationServices.stringForLocaleElseSystem(localeIdentifier: localeIdentifier, key: "favorites.favoriteLessons.details")
        openButtonTitle = localizationServices.stringForLocaleElseSystem(localeIdentifier: localeIdentifier, key: "open")
        
        layoutDirection = LayoutDirection.from(languageDirection: currentTranslationLanguage.direction)
    }
    
    private func reloadParallelLanguageName(_ parallelLanguage: LanguageDomainModel?) {
        
        let getLanguageAvailability = getLanguageAvailabilityUseCase.getLanguageAvailability(for: tool, language: parallelLanguage)
            
        if getLanguageAvailability.isAvailable {
            
            parallelLanguageName = getLanguageAvailability.availabilityString
            
        } else {
            parallelLanguageName = ""
        }
    }
}
