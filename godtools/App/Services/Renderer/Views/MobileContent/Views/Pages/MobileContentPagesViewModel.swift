//
//  MobileContentPagesViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 3/20/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit
import GodToolsToolParser
import Combine

class MobileContentPagesViewModel: NSObject {
    
    private let resourcesRepository: ResourcesRepository
    private let translationsRepository: TranslationsRepository
    private let mobileContentEventAnalytics: MobileContentEventAnalyticsTracking
    private let initialPageRenderingType: MobileContentPagesInitialPageRenderingType
    private let initialPage: MobileContentPagesPage
    
    private var safeArea: UIEdgeInsets?
    private var pageModels: [Page] = Array()
    private var languagelocaleIdUsed: Set<String> = Set()
    private var cancellables: Set<AnyCancellable> = Set()
    
    private(set) var renderer: CurrentValueSubject<MobileContentRenderer, Never>
    private(set) var currentPageRenderer: CurrentValueSubject<MobileContentPageRenderer, Never>
    private(set) var currentRenderedPageNumber: Int = 0
    private(set) var highestPageNumberViewed: Int = 0
    private(set) var trainingTipsEnabled: Bool = false
    
    private(set) weak var window: UIViewController?
    
    let rendererWillChangeSignal: Signal = Signal()
    let reRendererPagesSignal: SignalValue<MobileContentPagesReRenderPagesModel> = SignalValue()
    let navigatePageSignal: SignalValue<MobileContentPagesNavigateToPageModel> = SignalValue()
    let pagesRemovedSignal: SignalValue<[IndexPath]> = SignalValue()
    let incrementUserCounterUseCase: IncrementUserCounterUseCase
    
    init(renderer: MobileContentRenderer, initialPage: MobileContentPagesPage?, resourcesRepository: ResourcesRepository, translationsRepository: TranslationsRepository, mobileContentEventAnalytics: MobileContentEventAnalyticsTracking, initialPageRenderingType: MobileContentPagesInitialPageRenderingType, trainingTipsEnabled: Bool, incrementUserCounterUseCase: IncrementUserCounterUseCase) {
        
        self.renderer = CurrentValueSubject(renderer)
        self.currentPageRenderer = CurrentValueSubject(renderer.pageRenderers[0])
        self.initialPage = initialPage ?? .pageNumber(value: 0)
        self.resourcesRepository = resourcesRepository
        self.translationsRepository = translationsRepository
        self.mobileContentEventAnalytics = mobileContentEventAnalytics
        self.initialPageRenderingType = initialPageRenderingType
        self.trainingTipsEnabled = trainingTipsEnabled
        self.incrementUserCounterUseCase = incrementUserCounterUseCase
                
        super.init()
              
        resourcesRepository.getResourcesChanged()
            .receiveOnMain()
            .sink { [weak self] _ in
                self?.updateTranslationsIfNeeded()
            }
            .store(in: &cancellables)
        
        countLanguageUsage(localeId: currentPageRenderer.value.language.localeIdentifier)
    }
    
    var resource: ResourceModel {
        return renderer.value.resource
    }
    
    func viewDidFinishLayout(window: UIViewController, safeArea: UIEdgeInsets) {
        
        self.window = window
        self.safeArea = safeArea
        
        setRenderer(
            renderer: renderer.value,
            pageRendererIndex: nil,
            navigateToPage: initialPage
        )
    }
    
    func handleDismissToolEvent() {
        
        let event = DismissToolEvent(
            resource: resource,
            highestPageNumberViewed: highestPageNumberViewed
        )
        
        renderer.value.navigation.dismissTool(event: event)
    }
    
    func pageDidReceiveEvent(eventId: EventId) -> ProcessedEventResult? {
        
        trackContentEvent(eventId: eventId)
        
        let currentPageRenderer: MobileContentPageRenderer = currentPageRenderer.value
        
        if currentPageRenderer.manifest.dismissListeners.contains(eventId) {
            handleDismissToolEvent()
        }
        
        if let didReceivePageListenerForPageNumber = currentPageRenderer.getPageForListenerEvents(eventIds: [eventId]) {

            guard let navigateToPageModel = getNavigateToPageModel(
                page: .pageNumber(value: didReceivePageListenerForPageNumber),
                forceReloadPagesCollectionView: false,
                animated: true
            ) else {
                return nil
            }
            
            navigatePageSignal.accept(value: navigateToPageModel)
        }
        
        return nil
    }
    
    func setTrainingTipsEnabled(enabled: Bool) {
        
        guard trainingTipsEnabled != enabled else {
            return
        }
        
        trainingTipsEnabled = enabled
        
        setPageRenderer(pageRenderer: currentPageRenderer.value, navigateToPage: nil)
    }
    
    // MARK: - Renderer / Page Renderer
    
    var primaryPageRenderer: MobileContentPageRenderer {
        return renderer.value.pageRenderers[0]
    }
    
    func setRenderer(renderer: MobileContentRenderer, pageRendererIndex: Int?, navigateToPage: MobileContentPagesPage?) {
            
        let pageRenderer: MobileContentPageRenderer?
        
        if let pageRendererIndex = pageRendererIndex, pageRendererIndex >= 0 && pageRendererIndex < renderer.pageRenderers.count {
            pageRenderer = renderer.pageRenderers[pageRendererIndex]
        }
        else if let firstPageRenderer = renderer.pageRenderers.first {
            pageRenderer = firstPageRenderer
        }
        else {
            pageRenderer = nil
        }
        
        guard let pageRenderer = pageRenderer else {
            return
        }
        
        self.renderer.send(renderer)
                
        setPageRenderer(pageRenderer: pageRenderer, navigateToPage: navigateToPage)
    }
    
    func setPageRenderer(pageRenderer: MobileContentPageRenderer, navigateToPage: MobileContentPagesPage?) {
        
        countLanguageUsageIfLanguageChanged(updatedLanguage: pageRenderer.language)
        
        let pageRenderers: [MobileContentPageRenderer] = renderer.value.pageRenderers
        let pageModelsToRender: [Page]
        
        switch initialPageRenderingType {
        
        case .chooseYourOwnAdventure:
            
            let pagesShouldMatchRenderedPages: Bool = pageRenderers.count > 1 && pageModels.count > 1
            
            var newPageModelsToRenderer: [Page] = Array()
            
            if pagesShouldMatchRenderedPages {
                
                newPageModelsToRenderer = getRendererPageModelsMatchingCurrentRenderedPageModels(pageRenderer: pageRenderer)
            }
            
            if newPageModelsToRenderer.isEmpty && pageRenderer.getAllPageModels().count > 0 {
                
                newPageModelsToRenderer = [pageRenderer.getAllPageModels()[0]]
            }

            pageModelsToRender = newPageModelsToRenderer
            
        case .visiblePages:
            
            pageModelsToRender = pageRenderer.getVisiblePageModels()
        }
        
        rendererWillChangeSignal.accept()
        
        currentPageRenderer.send(pageRenderer)
                
        self.pageModels = pageModelsToRender
                
        let navigateToPageModel: MobileContentPagesNavigateToPageModel?
        
        if let navigateToPage = navigateToPage {
            navigateToPageModel = getNavigateToPageModel(page: navigateToPage, forceReloadPagesCollectionView: true, animated: false)
        }
        else {
            navigateToPageModel = nil
        }
        
        let reRenderPagesModel = MobileContentPagesReRenderPagesModel(
            pagesSemanticContentAttribute: UISemanticContentAttribute.from(languageDirection: renderer.value.primaryLanguage.direction),
            navigateToPageModel: navigateToPageModel
        )
        
        reRendererPagesSignal.accept(value: reRenderPagesModel)
    }
    
    func getNumberOfRenderedPages() -> Int {
        return pageModels.count
    }
    
    // MARK: - Page Life Cycle
    
    func pageWillAppear(page: Int) -> MobileContentView? {
        
        guard let window = self.window, let safeArea = self.safeArea else {
            return nil
        }
        
        guard page >= 0 && page < pageModels.count else {
            return nil
        }
                
        let renderPageResult: Result<MobileContentView, Error> =  currentPageRenderer.value.renderPageModel(
            pageModel: pageModels[page],
            page: page,
            numberOfPages: pageModels.count,
            window: window,
            safeArea: safeArea,
            trainingTipsEnabled: trainingTipsEnabled
        )
        
        switch renderPageResult {
        
        case .success(let mobileContentView):
            return mobileContentView
            
        case .failure( _):
            break
        }
        
        return nil
    }
    
    func pageDidAppear(page: Int) {
        
        currentRenderedPageNumber = page
        
        if page > highestPageNumberViewed {
            highestPageNumberViewed = page
        }
    }
    
    func pageDidDisappear(page: Int) {
              
        let didNavigateBack: Bool = currentRenderedPageNumber < page
        let shouldRemoveAllFollowingPages: Bool = initialPageRenderingType == .chooseYourOwnAdventure && didNavigateBack
        
        if shouldRemoveAllFollowingPages {
            removeFollowingPagesFromPage(page: currentRenderedPageNumber)
        }
        
        removePageIfHidden(page: page)
    }
    
    func didChangeMostVisiblePage(page: Int) {
        
        currentRenderedPageNumber = page
    }
}

// MARK: - Page Navigation

extension MobileContentPagesViewModel {
    
    private func getNavigateToPageModel(page: MobileContentPagesPage, forceReloadPagesCollectionView: Bool, animated: Bool) -> MobileContentPagesNavigateToPageModel? {
        
        let pageRenderer: MobileContentPageRenderer = currentPageRenderer.value
        let allPages: [Page] = pageRenderer.getAllPageModels()
        
        var shouldRenderNewPages: [Page]?
        let navigateToPageModel: Page
        
        switch page {
            
        case .pageId(let value):
                   
            guard let pageModelMatchingPageId = allPages.first(where: {$0.id == value}) else {
                return nil
            }
            
            var pageModelsToRenderUpToPageToNavigateTo: [Page] = [pageModelMatchingPageId]
            
            while true {
            
                guard let parentPage = pageModelsToRenderUpToPageToNavigateTo[0].parentPage else {
                    break
                }
                
                guard !pageModelsToRenderUpToPageToNavigateTo.contains(parentPage) else {
                    break
                }
                
                pageModelsToRenderUpToPageToNavigateTo.insert(parentPage, at: 0)
            }
            
            shouldRenderNewPages = pageModelsToRenderUpToPageToNavigateTo
            navigateToPageModel = pageModelMatchingPageId
            
        case .pageNumber(let value):
            
            let page: Page?
            
            if value >= 0 && value < allPages.count {
                page = allPages[value]
            }
            else {
                page = nil
            }
            
            guard let page = page else {
                return nil
            }

            if page.isHidden || initialPageRenderingType == .chooseYourOwnAdventure {
                
                let insertAtPage: Int = currentRenderedPageNumber + 1
                
                var pageModelsToRenderUpToPageToNavigateTo: [Page] = pageModels
                
                if insertAtPage < pageModels.count {
                    
                    pageModelsToRenderUpToPageToNavigateTo.insert(page, at: insertAtPage)
                }
                else {
                    pageModelsToRenderUpToPageToNavigateTo.append(page)
                }
                
                shouldRenderNewPages = pageModelsToRenderUpToPageToNavigateTo
                navigateToPageModel = page
            }
            else {
                
                navigateToPageModel = page
            }
        }
        
        let shouldReloadPagesUI: Bool = shouldRenderNewPages != nil
        
        if let shouldRenderNewPages = shouldRenderNewPages {
            pageModels = shouldRenderNewPages
        }

        guard let navigateToPageNumber = pageModels.firstIndex(of: navigateToPageModel) else {
            return nil
        }
        
        let reloadPagesCollectionViewNeeded: Bool = shouldReloadPagesUI || forceReloadPagesCollectionView
                
        return MobileContentPagesNavigateToPageModel(
            reloadPagesCollectionViewNeeded: reloadPagesCollectionViewNeeded,
            page: navigateToPageNumber,
            pagePositions: nil,
            animated: animated
        )
    }
}

// MARK: - Private

extension MobileContentPagesViewModel {
    
    private func updateTranslationsIfNeeded() {
        
        var translationsNeededDownloading: [TranslationModel] = Array()
                
        for pageRenderer in renderer.value.pageRenderers {
            
            let resource: ResourceModel = pageRenderer.resource
            let language: LanguageDomainModel = pageRenderer.language
            let currentTranslation: TranslationModel = pageRenderer.translation
            
            guard let latestTranslation = translationsRepository.getLatestTranslation(resourceId: resource.id, languageId: language.id) else {
                continue
            }
            
            guard latestTranslation.version > currentTranslation.version else {
                continue
            }
            
            translationsNeededDownloading.append(latestTranslation)
        }
        
        guard !translationsNeededDownloading.isEmpty else {
            return
        }
        
        translationsRepository.getTranslationManifestsFromRemote(translations: translationsNeededDownloading, manifestParserType: .renderer, includeRelatedFiles: true, shouldFallbackToLatestDownloadedTranslationIfRemoteFails: false)
            .receiveOnMain()
            .sink { _ in
                
            } receiveValue: { [weak self] (manifestFileDataModels: [TranslationManifestFileDataModel]) in
                
                guard let weakSelf = self else {
                    return
                }
                
                let currentRenderer: MobileContentRenderer = weakSelf.renderer.value
                let currentPageRenderer: MobileContentPageRenderer = weakSelf.currentPageRenderer.value
                
                var languageTranslationManifests: [MobileContentRendererLanguageTranslationManifest] = Array()
                                
                for pageRenderer in currentRenderer.pageRenderers {
                    
                    let resource: ResourceModel = pageRenderer.resource
                    let language: LanguageDomainModel = pageRenderer.language
                    let currentTranslation: TranslationModel = pageRenderer.translation
                    
                    let updatedManifest: Manifest
                    let updatedTranslation: TranslationModel
                    
                    if let latestTranslation = self?.translationsRepository.getLatestTranslation(resourceId: resource.id, languageId: language.id), latestTranslation.version > currentTranslation.version, let manifestFileDataModel = manifestFileDataModels.filter({$0.translation.id == latestTranslation.id}).first {
                        
                        updatedManifest = manifestFileDataModel.manifest
                        updatedTranslation = manifestFileDataModel.translation
                    }
                    else {
                        
                        updatedManifest = pageRenderer.manifest
                        updatedTranslation = pageRenderer.translation
                    }
                    
                    let languageTranslationManifest = MobileContentRendererLanguageTranslationManifest(
                        manifest: updatedManifest,
                        language: pageRenderer.language,
                        translation: updatedTranslation
                    )
                    
                    languageTranslationManifests.append(languageTranslationManifest)
                }
                
                let toolTranslations = ToolTranslationsDomainModel(
                    tool: currentRenderer.resource,
                    languageTranslationManifests: languageTranslationManifests
                )
                
                let updatedRenderer: MobileContentRenderer = currentRenderer.copy(toolTranslations: toolTranslations)
                
                let pageRendererIndex: Int? = currentRenderer.pageRenderers.firstIndex(where: {$0.language.id == currentPageRenderer.language.id})
                
                self?.setRenderer(renderer: updatedRenderer, pageRendererIndex: pageRendererIndex, navigateToPage: nil)
            }
            .store(in: &cancellables)
    }
    
    private func getRendererPageModelsMatchingCurrentRenderedPageModels(pageRenderer: MobileContentPageRenderer) -> [Page] {
        
        var rendererPageModelsMatchingCurrentRenderedPageModels: [Page] = Array()
        
        let currentRenderedPageModels: [Page] = pageModels
        let allPageModelsInNewRenderer: [Page] = pageRenderer.getAllPageModels()
        
        for pageModel in currentRenderedPageModels {
                        
            guard let setRendererPageModel = allPageModelsInNewRenderer.filter({$0.id == pageModel.id}).first else {
                continue
            }
            
            rendererPageModelsMatchingCurrentRenderedPageModels.append(setRendererPageModel)
        }
        
        return rendererPageModelsMatchingCurrentRenderedPageModels
    }
    
    private func removePage(page: Int) {
        
        let pageIsInArrayBounds: Bool = page >= 0 && page < pageModels.count
        
        guard pageIsInArrayBounds else {
            return
        }
        
        pageModels.remove(at: page)
        pagesRemovedSignal.accept(value: [IndexPath(item: page, section: 0)])
    }
    
    private func removeFollowingPagesFromPage(page: Int) {
        
        let nextPage: Int = currentRenderedPageNumber + 1
        
        for index in nextPage ..< pageModels.count {
            removePage(page: index)
        }
    }
    
    private func removePageIfHidden(page: Int) {
        
        let indexIsInRange: Bool = page >= 0 && page < pageModels.count
        
        guard indexIsInRange else {
            return
        }
        
        let lastViewedPageModel: Page = pageModels[page]
        
        guard lastViewedPageModel.isHidden else {
            return
        }
        
        removePage(page: page)
    }
    
    private func trackContentEvent(eventId: EventId) {
        
        let language: LanguageDomainModel = currentPageRenderer.value.language
        
        mobileContentEventAnalytics.trackContentEvent(
            eventId: eventId,
            resource: resource,
            language: language
        )
    }
    
    private func countLanguageUsageIfLanguageChanged(updatedLanguage: LanguageDomainModel) {
        
        let updatedLocaleId = updatedLanguage.localeIdentifier
        let languageChanged: Bool = currentPageRenderer.value.language.localeIdentifier != updatedLocaleId
        
        if languageChanged {
            
            countLanguageUsage(localeId: updatedLocaleId)
        }
    }
    
    private func countLanguageUsage(localeId: String) {
        
        if languageUsageAlreadyCountedThisSession(localeId: localeId) { return }
        
        let locale = Locale(identifier: localeId)
        
        incrementUserCounterUseCase.incrementUserCounter(for: .languageUsed(locale: locale))
            .sink { completion in
                
                switch completion {
                case .finished:
                    self.trackLanguageUsageCountedThisSession(localeId: localeId)
                    
                case .failure:
                    break
                }
                
            } receiveValue: { _ in
                
            }
            .store(in: &cancellables)
    }
    
    private func languageUsageAlreadyCountedThisSession(localeId: String) -> Bool {
        return languagelocaleIdUsed.contains(localeId)
    }
    
    private func trackLanguageUsageCountedThisSession(localeId: String) {
        languagelocaleIdUsed.insert(localeId)
    }
}
