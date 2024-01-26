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

class MobileContentPagesViewModel: NSObject, ObservableObject {
    
    private let resourcesRepository: ResourcesRepository
    private let translationsRepository: TranslationsRepository
    private let mobileContentEventAnalytics: MobileContentRendererEventAnalyticsTracking
    private let initialPageRenderingType: MobileContentPagesInitialPageRenderingType
    private let initialPage: MobileContentPagesPage
    private let initialSelectedLanguageIndex: Int
    
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
    
    @Published private(set) var selectedLanguageIndex: Int
    
    let rendererWillChangeSignal: Signal = Signal()
    let pageNavigationEventSignal: SignalValue<MobileContentPagesNavigationEvent> = SignalValue()
    let pagesRemovedSignal: SignalValue<[Int]> = SignalValue()
    let incrementUserCounterUseCase: IncrementUserCounterUseCase
    
    init(renderer: MobileContentRenderer, initialPage: MobileContentPagesPage?, resourcesRepository: ResourcesRepository, translationsRepository: TranslationsRepository, mobileContentEventAnalytics: MobileContentRendererEventAnalyticsTracking, initialPageRenderingType: MobileContentPagesInitialPageRenderingType, trainingTipsEnabled: Bool, incrementUserCounterUseCase: IncrementUserCounterUseCase, selectedLanguageIndex: Int?) {
        
        self.renderer = CurrentValueSubject(renderer)
        self.currentPageRenderer = CurrentValueSubject(renderer.pageRenderers[0])
        self.initialPage = initialPage ?? .pageNumber(value: 0)
        self.resourcesRepository = resourcesRepository
        self.translationsRepository = translationsRepository
        self.mobileContentEventAnalytics = mobileContentEventAnalytics
        self.initialPageRenderingType = initialPageRenderingType
        self.trainingTipsEnabled = trainingTipsEnabled
        self.incrementUserCounterUseCase = incrementUserCounterUseCase
        self.initialSelectedLanguageIndex = selectedLanguageIndex ?? 0
        self.selectedLanguageIndex = initialSelectedLanguageIndex
                
        super.init()
              
        resourcesRepository.getResourcesChangedPublisher()
            .receive(on: DispatchQueue.main)
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
        
        incrementToolOpenUserCounter()
        
        setRenderer(renderer: renderer.value, pageRendererIndex: selectedLanguageIndex, navigationEvent: nil)
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
        
        _ = checkIfEventIsPageListenerAndNavigate(eventId: eventId)
                
        return nil
    }
    
    func setTrainingTipsEnabled(enabled: Bool) {
        
        guard trainingTipsEnabled != enabled else {
            return
        }
        
        trainingTipsEnabled = enabled
        
        setPageRenderer(pageRenderer: currentPageRenderer.value, navigationEvent: nil, pagePositions: nil)
    }
    
    // MARK: - Renderer / Page Renderer
    
    var primaryPageRenderer: MobileContentPageRenderer {
        return renderer.value.pageRenderers[0]
    }
    
    var layoutDirection: UISemanticContentAttribute {
        return UISemanticContentAttribute.from(languageDirection: renderer.value.primaryLanguage.direction)
    }
    
    func setRenderer(renderer: MobileContentRenderer, pageRendererIndex: Int?, navigationEvent: MobileContentPagesNavigationEvent?) {
            
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
                
        setPageRenderer(pageRenderer: pageRenderer, navigationEvent: navigationEvent, pagePositions: nil)
    }
    
    func setPageRenderer(pageRenderer: MobileContentPageRenderer, navigationEvent: MobileContentPagesNavigationEvent?, pagePositions: MobileContentViewPositionState?) {
            
        countLanguageUsageIfLanguageChanged(updatedLanguage: pageRenderer.language)
        
        currentPageRenderer.send(pageRenderer)
        
        let isInitialPageRender: Bool = pageModels.isEmpty
        
        let navigationEventToSend: MobileContentPagesNavigationEvent

        if isInitialPageRender {
            
            pageModels = getInitialPages(pageRenderer: pageRenderer)
        }
        else {
            
            pageModels = getPagesFromPageRendererMatchingPages(pages: pageModels, pagesFromPageRenderer: pageRenderer)
        }
        
        if let navigationEvent = navigationEvent {
            
            navigationEventToSend = navigationEvent
        }
        else if isInitialPageRender, let intialNavigationEvent = getInitialPageNavigation(pageRenderer: pageRenderer) {
            
            navigationEventToSend = intialNavigationEvent
        }
        else {
            
            navigationEventToSend = MobileContentPagesNavigationEvent(
                pageNavigation: PageNavigationCollectionViewNavigationModel(
                    navigationDirection: layoutDirection,
                    page: currentRenderedPageNumber,
                    animated: false,
                    reloadCollectionViewDataNeeded: true,
                    insertPages: nil
                ),
                pagePositions: pagePositions
            )
        }
                
        let eventWithCorrectLanguageDirection: MobileContentPagesNavigationEvent = MobileContentPagesNavigationEvent(
            pageNavigation: PageNavigationCollectionViewNavigationModel(
                navigationDirection: layoutDirection,
                page: navigationEventToSend.pageNavigation.page,
                animated: navigationEventToSend.pageNavigation.animated,
                reloadCollectionViewDataNeeded: navigationEventToSend.pageNavigation.reloadCollectionViewDataNeeded,
                insertPages: nil
            ),
            pagePositions: navigationEventToSend.pagePositions
        )
        
        sendPageNavigationEvent(navigationEvent: eventWithCorrectLanguageDirection)
        
        let pageRenderers: [MobileContentPageRenderer] = renderer.value.pageRenderers
        let pageRendererIndex: Int = pageRenderers.firstIndex(where: { $0.language.id == pageRenderer.language.id }) ?? 0
        
        selectedLanguageIndex = pageRendererIndex
    }
    
    func getNumberOfRenderedPages() -> Int {
        return pageModels.count
    }
    
    private func getInitialPageNavigation(pageRenderer: MobileContentPageRenderer) -> MobileContentPagesNavigationEvent? {
            
        guard let initialPage = getInitialPageModel(pageRenderer: pageRenderer) else {
            return nil
        }
        
        return getPageNavigationEvent(page: initialPage, animated: false, reloadCollectionViewDataNeeded: true)
    }
    
    private func getInitialPages(pageRenderer: MobileContentPageRenderer) -> [Page] {
            
        switch initialPageRenderingType {
        
        case .chooseYourOwnAdventure:
            
            let allPages: [Page] = pageRenderer.getAllPageModels()
            
            if let introPage = allPages.first {
                return [introPage]
            }
            
            return []
        
        case .visiblePages:
            return pageRenderer.getVisiblePageModels()
        }
    }
    
    private func getInitialPageModel(pageRenderer: MobileContentPageRenderer) -> Page? {
            
        let allPages: [Page] = pageRenderer.getAllPageModels()
                
        switch initialPage {
        
        case .pageId(let value):
            return allPages.first(where: {$0.id == value})
       
        case .pageNumber(let value):
            
            if value >= 0 && value < allPages.count {
                return allPages[value]
            }
            
            return nil
        }
    }
    
    private func getPagesFromPageRendererMatchingPages(pages: [Page], pagesFromPageRenderer: MobileContentPageRenderer) -> [Page] {
            
        var matchingPagesFromPageRenderer: [Page] = Array()
        
        let allPagesInPageRenderer: [Page] = pagesFromPageRenderer.getAllPageModels()
        
        for page in pages {
                        
            guard let matchingPage = allPagesInPageRenderer.filter({$0.id == page.id}).first else {
                continue
            }
            
            matchingPagesFromPageRenderer.append(matchingPage)
        }
        
        return matchingPagesFromPageRenderer
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
        
        if page >= 0 && page < pageModels.count {
            
            let currentPage: Page = pageModels[page]
            
            updateCachedPageDataForPageChange(currentPage: currentPage)
        }
        
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

// MARK: - Pages Data Cache

extension MobileContentPagesViewModel {
    
    private func updateCachedPageDataForPageChange(currentPage: Page) {
        
        guard let currentPageIndex = pageModels.firstIndex(of: currentPage) else {
            return
        }

        let currentPageRendererPagesViewDataCache: MobileContentPageRendererPagesViewDataCache = currentPageRenderer.value.pagesViewDataCache
        
        var cachedPageDataToKeep: [Page: MobileContentPageViewDataCache] = Dictionary()
        
        let cachedPageDataToKeepStartNumber: Int = currentPageIndex - 1
        let cachedPageDataToKeepEndNumber: Int = currentPageIndex + 1
        
        for pageNumber in cachedPageDataToKeepStartNumber ... cachedPageDataToKeepEndNumber {
            
            guard pageNumber >= 0 && pageNumber < pageModels.count else {
                continue
            }
            
            let pageModel: Page = pageModels[pageNumber]
            
            let pageViewDataCache: MobileContentPageViewDataCache = currentPageRendererPagesViewDataCache.getPageViewDataCache(page: pageModel)
            
            guard !pageViewDataCache.isEmpty else {
                continue
            }
            
            cachedPageDataToKeep[pageModel] = pageViewDataCache
        }
        
        currentPageRendererPagesViewDataCache.clearCache()
        
        for (page, pageViewDataCache) in cachedPageDataToKeep {
            currentPageRendererPagesViewDataCache.storePageViewDataCache(page: page, pageViewDataCache: pageViewDataCache)
        }
    }
}

// MARK: - Page Navigation

extension MobileContentPagesViewModel {
    
    private func checkIfEventIsPageListenerAndNavigate(eventId: EventId) -> Bool {
            
        let allPages: [Page] = currentPageRenderer.value.getAllPageModels()
        
        guard let pageListeningForEvent = allPages.first(where: {$0.listeners.contains(eventId)}) else {
            return false
        }
                
        navigateToPage(page: pageListeningForEvent, animated: true)
        
        return true
    }
        
    func navigateToPage(page: Page, animated: Bool) {
        
        let navigationEvent: MobileContentPagesNavigationEvent = getPageNavigationEvent(page: page, animated: animated, reloadCollectionViewDataNeeded: false)
        
        sendPageNavigationEvent(navigationEvent: navigationEvent)
    }
        
    private func getPageNavigationEvent(page: Page, animated: Bool, reloadCollectionViewDataNeeded: Bool) -> MobileContentPagesNavigationEvent {
        
        let navigationEvent: MobileContentPagesNavigationEvent
        
        if let pageIndex = pageModels.firstIndex(where: {$0.id == page.id}) {
            
            navigationEvent = MobileContentPagesNavigationEvent(
                pageNavigation: PageNavigationCollectionViewNavigationModel(
                    navigationDirection: nil,
                    page: pageIndex,
                    animated: animated,
                    reloadCollectionViewDataNeeded: reloadCollectionViewDataNeeded,
                    insertPages: nil
                ),
                pagePositions: nil
            )
        }
        else {
            
            let pagePosition: Int32 = page.position
            let lastPageIndex: Int = pageModels.count - 1
            
            var insertAtIndex: Int = lastPageIndex
            
            for index in 0 ..< pageModels.count {
                
                let currentPagePosition: Int32 = pageModels[index].position
                
                if currentPagePosition > pagePosition {
                    insertAtIndex = index
                    break
                }
                else if index == lastPageIndex {
                    insertAtIndex = lastPageIndex + 1
                }
            }
            
            pageModels.insert(page, at: insertAtIndex)
            
            navigationEvent = MobileContentPagesNavigationEvent(
                pageNavigation: PageNavigationCollectionViewNavigationModel(
                    navigationDirection: nil,
                    page: insertAtIndex,
                    animated: animated,
                    reloadCollectionViewDataNeeded: reloadCollectionViewDataNeeded,
                    insertPages: [insertAtIndex]
                ),
                pagePositions: nil
            )
        }
        
        return navigationEvent
    }
    
    func sendPageNavigationEvent(navigationEvent: MobileContentPagesNavigationEvent) {
            
        pageNavigationEventSignal.accept(value: navigationEvent)
    }
    
    /*
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
    }*/
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
            .receive(on: DispatchQueue.main)
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
                
                self?.setRenderer(renderer: updatedRenderer, pageRendererIndex: pageRendererIndex, navigationEvent: nil)
            }
            .store(in: &cancellables)
    }
    
    private func removePage(page: Int) {
        
        let pageIsInArrayBounds: Bool = page >= 0 && page < pageModels.count
        
        guard pageIsInArrayBounds else {
            return
        }
        
        pageModels.remove(at: page)
        pagesRemovedSignal.accept(value: [page])
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
    
    private func incrementToolOpenUserCounter() {
        
        let toolOpenInteraction: IncrementUserCounterUseCase.UserCounterInteraction?
        
        if resource.isToolType {
            toolOpenInteraction = .toolOpen(tool: resource.id)
        }
        else if resource.isLessonType {
            toolOpenInteraction = .lessonOpen(tool: resource.id)
        }
        else {
            toolOpenInteraction = nil
        }
        
        guard let toolOpenInteraction = toolOpenInteraction else {
            return
        }
        
        incrementUserCounterUseCase.incrementUserCounter(for: toolOpenInteraction)
            .sink { _ in
                
            } receiveValue: { _ in
                
            }
            .store(in: &cancellables)
    }
    
    private func trackLanguageUsageCountedThisSession(localeId: String) {
        languagelocaleIdUsed.insert(localeId)
    }
}
