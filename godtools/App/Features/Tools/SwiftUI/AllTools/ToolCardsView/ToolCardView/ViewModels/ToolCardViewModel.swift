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

class ToolCardViewModel: BaseToolCardViewModel, ResourceItemInitialDownloadProgress {
    
    // MARK: - Properties
    
    let tool: ToolDomainModel
    let dataDownloader: InitialDataDownloader
    private let languageSettingsService: LanguageSettingsService
    private let localizationServices: LocalizationServices
    
    private let getBannerImageUseCase: GetBannerImageUseCase
    private let getLanguageAvailabilityStringUseCase: GetLanguageAvailabilityStringUseCase
    private let getToolIsFavoritedUseCase: GetToolIsFavoritedUseCase
    
    private weak var delegate: ToolCardViewModelDelegate?
    
    var attachmentsDownloadProgress: ObservableValue<Double> = ObservableValue(value: 0)
    var translationDownloadProgress: ObservableValue<Double> = ObservableValue(value: 0)
    var downloadAttachmentsReceipt: DownloadAttachmentsReceipt?
    var downloadResourceTranslationsReceipt: DownloadTranslationsReceipt?
    
    private var cancellables = Set<AnyCancellable>()
    
    var resourceId: String { tool.id }
    
    // MARK: - Init
    
    init(tool: ToolDomainModel, dataDownloader: InitialDataDownloader, languageSettingsService: LanguageSettingsService, localizationServices: LocalizationServices, getBannerImageUseCase: GetBannerImageUseCase, getLanguageAvailabilityStringUseCase: GetLanguageAvailabilityStringUseCase, getToolIsFavoritedUseCase: GetToolIsFavoritedUseCase, delegate: ToolCardViewModelDelegate?) {
        
        self.tool = tool
        self.dataDownloader = dataDownloader
        self.languageSettingsService = languageSettingsService
        self.localizationServices = localizationServices
        self.getBannerImageUseCase = getBannerImageUseCase
        self.getLanguageAvailabilityStringUseCase = getLanguageAvailabilityStringUseCase
        self.getToolIsFavoritedUseCase = getToolIsFavoritedUseCase
        self.delegate = delegate
        
        super.init()
        
        setup()
    }
    
    deinit {
        
        removeDataDownloaderObservers()
        
        attachmentsDownloadProgress.removeObserver(self)
        translationDownloadProgress.removeObserver(self)
        languageSettingsService.primaryLanguage.removeObserver(self)
        languageSettingsService.parallelLanguage.removeObserver(self)
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
        setupBinding()
    }
    
    private func setupBinding() {
        
        addDataDownloaderObservers()
        
        attachmentsDownloadProgress.addObserver(self) { [weak self] (progress: Double) in
            DispatchQueue.main.async {
                withAnimation {
                    self?.attachmentsDownloadProgressValue = progress
                }
            }
        }
        
        getBannerImageUseCase.getBannerImagePublisher(for: tool.bannerImageId)
            .receiveOnMain()
            .assign(to: \.bannerImage, on: self)
            .store(in: &cancellables)
        
        translationDownloadProgress.addObserver(self) { [weak self] (progress: Double) in
            DispatchQueue.main.async {
                withAnimation {
                    self?.translationDownloadProgressValue = progress
                }
            }
        }
        
        getToolIsFavoritedUseCase.getToolIsFavoritedPublisher(toolId: tool.id)
            .receiveOnMain()
            .assign(to: \.isFavorited, on: self)
            .store(in: &cancellables)
        
        languageSettingsService.parallelLanguage.addObserver(self) { [weak self] (parallelLanguage: LanguageModel?) in
            DispatchQueue.main.async { [weak self] in
                self?.reloadParallelLanguageName()
            }
        }
        
        tool.currentTranslationPublisher
            .receiveOnMain()
            .sink { currentTranslationToUse in
                self.reloadStrings(for: currentTranslationToUse)
            }
            .store(in: &cancellables)
        
        tool.namePublisher
            .receiveOnMain()
            .assign(to: \.title, on: self)
            .store(in: &cancellables)
    }
        
    private func reloadStrings(for currentTranslation: CurrentToolTranslationDomainModel) {
        let bundleLoader = localizationServices.bundleLoader
        
        let languageBundle: Bundle
        let languageDirection: LanguageDirectionDomainModel
        
        switch currentTranslation {
        case .primaryLanguage(let language, _):
            
            languageBundle = bundleLoader.bundleForResource(resourceName: language.localeIdentifier) ?? Bundle.main
            languageDirection = language.direction
            
        case .englishFallback(_):
            
            languageBundle = bundleLoader.englishBundle ?? Bundle.main
            languageDirection = .leftToRight
        }
        
        category = localizationServices.toolCategoryStringForBundle(bundle: languageBundle, attrCategory: tool.category)
        detailsButtonTitle = localizationServices.stringForBundle(bundle: languageBundle, key: "favorites.favoriteLessons.details")
        openButtonTitle = localizationServices.stringForBundle(bundle: languageBundle, key: "open")
        layoutDirection = LayoutDirection.from(languageDirection: languageDirection)
    }
    
    private func reloadParallelLanguageName() {
        let parallelLanguage = languageSettingsService.parallelLanguage.value
        
        let getLanguageAvailability = getLanguageAvailabilityStringUseCase.getLanguageAvailability(for: tool, language: parallelLanguage)
        
        if getLanguageAvailability.isAvailable {
            
            parallelLanguageName = getLanguageAvailability.string
            
        } else {
            
            parallelLanguageName = ""
        }
    }
}
