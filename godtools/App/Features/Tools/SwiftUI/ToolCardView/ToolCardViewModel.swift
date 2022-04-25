//
//  ToolCardViewModel.swift
//  godtools
//
//  Created by Rachael Skeath on 4/11/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import SwiftUI

class ToolCardViewModel: NSObject, ObservableObject {
    
    // MARK: - Properties
    
    private let resourceId: String
    
    private let getBannerImageUseCase: GetBannerImageUseCase
    private let getToolDataUseCase: GetToolDataUseCase
    private let getLanguageNameUseCase: GetLanguageNameUseCase
    
    private let favoritedResourcesCache: FavoritedResourcesCache
    private let languageSettingsService: LanguageSettingsService
    
    // MARK: - Published
    
    @Published var bannerImage: Image?
    @Published var isFavorited = false
    @Published var title: String = ""
    @Published var category: String = ""
    @Published var parallelLanguageName: String = ""
    @Published var layoutDirection: LayoutDirection = .leftToRight
    
    // MARK: - Init
    
    init(resourceId: String, getBannerImageUseCase: GetBannerImageUseCase, getToolDataUseCase: GetToolDataUseCase, getLanguageNameUseCase: GetLanguageNameUseCase, favoritedResourcesCache: FavoritedResourcesCache, languageSettingsService: LanguageSettingsService) {
        
        self.resourceId = resourceId
        self.getBannerImageUseCase = getBannerImageUseCase
        self.getToolDataUseCase = getToolDataUseCase
        self.getLanguageNameUseCase = getLanguageNameUseCase
        self.favoritedResourcesCache = favoritedResourcesCache
        self.languageSettingsService = languageSettingsService
                
        super.init()
        
        setupPublishedProperties()
        setupBinding()
    }
    
    deinit {
        favoritedResourcesCache.resourceFavorited.removeObserver(self)
        favoritedResourcesCache.resourceUnfavorited.removeObserver(self)
        languageSettingsService.primaryLanguage.removeObserver(self)
        languageSettingsService.parallelLanguage.removeObserver(self)
    }
}
 
// MARK: - Public

extension ToolCardViewModel {
    
    func favoritedButtonTapped() {
        favoritedResourcesCache.toggleFavorited(resourceId: resourceId)
    }
}
 
// MARK: - Private

extension ToolCardViewModel {
    
    private func setupPublishedProperties() {
        bannerImage = getBannerImageUseCase.getBannerImage()
        isFavorited = favoritedResourcesCache.isFavorited(resourceId: resourceId)
        
        reloadDataForPrimaryLanguage()
    }
    
    private func setupBinding() {
        favoritedResourcesCache.resourceFavorited.addObserver(self) { [weak self] (resourceId: String) in
            guard let self = self else { return }

            if resourceId == self.resourceId {
                DispatchQueue.main.async { [weak self] in
                    self?.isFavorited = true
                }
            }
        }
        favoritedResourcesCache.resourceUnfavorited.addObserver(self) { [weak self] (resourceId: String) in
            guard let self = self else { return }

            if resourceId == self.resourceId {
                DispatchQueue.main.async { [weak self] in
                    self?.isFavorited = false
                }
            }
        }
        
        languageSettingsService.primaryLanguage.addObserver(self) { [weak self] (primaryLanguage: LanguageModel?) in
            DispatchQueue.main.async { [weak self] in
                self?.reloadDataForPrimaryLanguage()
            }
        }
        languageSettingsService.parallelLanguage.addObserver(self) { [weak self] (parallelLanguage: LanguageModel?) in
            DispatchQueue.main.async { [weak self] in
                self?.reloadParallelLanguageName()
            }
        }
    }
    
    private func reloadDataForPrimaryLanguage() {
        let toolData = getToolDataUseCase.getToolData()
        title = toolData.title
        category = toolData.category
        layoutDirection = LayoutDirection.from(languageDirection: toolData.languageDirection)
    }
    
    private func reloadParallelLanguageName() {
        let parallelLanguage = languageSettingsService.parallelLanguage.value
        parallelLanguageName = getLanguageNameUseCase.getLanguageName(language: parallelLanguage)
    }
}
