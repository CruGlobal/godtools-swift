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
    private let getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase
    private let translatedLanguageNameRepository: TranslatedLanguageNameRepository
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
    
    @Published private(set) var appLanguage: AppLanguageDomainModel = LanguageCodeDomainModel.english.rawValue
    @Published private(set) var languages: [LanguageDomainModel] = Array()
    @Published private(set) var languageNames: [String] = Array()
    @Published private(set) var selectedLanguageIndex: Int
    
    let rendererWillChangeSignal: Signal = Signal()
    let pageNavigationEventSignal: SignalValue<MobileContentPagesNavigationEvent> = SignalValue()
    let incrementUserCounterUseCase: IncrementUserCounterUseCase
    
    init(renderer: MobileContentRenderer, initialPage: MobileContentPagesPage?, resourcesRepository: ResourcesRepository, translationsRepository: TranslationsRepository, mobileContentEventAnalytics: MobileContentRendererEventAnalyticsTracking, getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase, translatedLanguageNameRepository: TranslatedLanguageNameRepository, initialPageRenderingType: MobileContentPagesInitialPageRenderingType, trainingTipsEnabled: Bool, incrementUserCounterUseCase: IncrementUserCounterUseCase, selectedLanguageIndex: Int?) {
        
        self.renderer = CurrentValueSubject(renderer)
        self.currentPageRenderer = CurrentValueSubject(renderer.pageRenderers[0])
        self.initialPage = initialPage ?? .pageNumber(value: 0)
        self.resourcesRepository = resourcesRepository
        self.translationsRepository = translationsRepository
        self.mobileContentEventAnalytics = mobileContentEventAnalytics
        self.getCurrentAppLanguageUseCase = getCurrentAppLanguageUseCase
        self.translatedLanguageNameRepository = translatedLanguageNameRepository
        self.initialPageRenderingType = initialPageRenderingType
        self.trainingTipsEnabled = trainingTipsEnabled
        self.incrementUserCounterUseCase = incrementUserCounterUseCase
        self.initialSelectedLanguageIndex = selectedLanguageIndex ?? 0
        self.selectedLanguageIndex = initialSelectedLanguageIndex
                
        super.init()
        
        getCurrentAppLanguageUseCase
            .getLanguagePublisher()
            .assign(to: &$appLanguage)
        
        Publishers.CombineLatest(
            $languages.eraseToAnyPublisher(),
            $appLanguage.eraseToAnyPublisher()
        )
        .receive(on: DispatchQueue.main)
        .sink { [weak self] (languages: [LanguageDomainModel], appLanguage: AppLanguageDomainModel) in
            
            self?.languageNames = languages.map({ (language: LanguageDomainModel) in
                translatedLanguageNameRepository.getLanguageName(language: language.localeIdentifier, translatedInLanguage: appLanguage)
            })
        }
        .store(in: &cancellables)
              
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
    
    func getSelectedLanguage() -> LanguageDomainModel? {
        
        guard selectedLanguageIndex >= 0 && selectedLanguageIndex < languages.count else {
            return nil
        }
        
        return languages[selectedLanguageIndex]
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
    
    func getPages() -> [Page] {
        return pageModels
    }
    
    func setPages(pages: [Page]) {
        pageModels = pages
    }

    func getCurrentPage() -> Page? {
        return getPage(index: currentRenderedPageNumber)
    }
    
    func getPage(index: Int) -> Page? {
        
        guard index >= 0 && index < pageModels.count else {
            return nil
        }
        
        return pageModels[index]
    }
    
    // MARK: - Renderer / Page Renderer
    
    var primaryPageRenderer: MobileContentPageRenderer {
        return renderer.value.pageRenderers[0]
    }
    
    var layoutDirection: UISemanticContentAttribute {
        return UISemanticContentAttribute.from(languageDirection: renderer.value.primaryLanguage.direction)
    }
    
    func setRendererPrimaryLanguage(primaryLanguageId: String, parallelLanguageId: String?, selectedLanguageId: String?) {
        
        let currentRenderer: MobileContentRenderer = renderer.value
        
        var newLanguageIds: [String] = [primaryLanguageId]
        
        if let parallelLanguageId = parallelLanguageId {
            newLanguageIds.append(parallelLanguageId)
        }
        
        let newSelectedLanguageIndex: Int? = newLanguageIds.firstIndex(where: {$0 == selectedLanguageId})
        
        let didDownloadToolTranslationsClosure = { [weak self] (result: Result<ToolTranslationsDomainModel, Error>) in
                   
            switch result {
            
            case .success(let toolTranslations):
                
                let newRenderer: MobileContentRenderer = currentRenderer.copy(toolTranslations: toolTranslations)
                
                self?.setRenderer(renderer: newRenderer, pageRendererIndex: newSelectedLanguageIndex, navigationEvent: nil)
                
            case .failure( _):
                break
            }
        }
        
        currentRenderer.navigation.downloadToolLanguages(
            toolId: currentRenderer.resource.id,
            languageIds: newLanguageIds,
            completion: didDownloadToolTranslationsClosure
        )
    }
    
    func setRendererTranslations(toolTranslations: ToolTranslationsDomainModel, pageRendererIndex: Int?) {
        
        let newRenderer: MobileContentRenderer = renderer.value.copy(toolTranslations: toolTranslations)
        
        setRenderer(renderer: newRenderer, pageRendererIndex: pageRendererIndex, navigationEvent: nil)
    }
    
    func setRenderer(renderer: MobileContentRenderer, pageRendererIndex: Int?, navigationEvent: MobileContentPagesNavigationEvent?) {
            
        languages = renderer.pageRenderers.map({$0.language})
        
        let pageRenderer: MobileContentPageRenderer?
        let pageRendererIndex: Int = pageRendererIndex ?? selectedLanguageIndex
        
        if pageRendererIndex >= 0 && pageRendererIndex < renderer.pageRenderers.count {
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
        
        rendererWillChangeSignal.accept()
        
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
                    insertPages: nil,
                    deletePages: nil
                ),
                setPages: nil,
                pagePositions: pagePositions
            )
        }
                
        let eventWithCorrectLanguageDirection: MobileContentPagesNavigationEvent = MobileContentPagesNavigationEvent(
            pageNavigation: PageNavigationCollectionViewNavigationModel(
                navigationDirection: layoutDirection,
                page: navigationEventToSend.pageNavigation.page,
                animated: navigationEventToSend.pageNavigation.animated,
                reloadCollectionViewDataNeeded: navigationEventToSend.pageNavigation.reloadCollectionViewDataNeeded,
                insertPages: nil,
                deletePages: nil
            ),
            setPages: nil,
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
    
    func getInitialPages(pageRenderer: MobileContentPageRenderer) -> [Page] {
            
        return pageRenderer.getVisiblePageModels()
    }
    
    func getPagesFromPageRendererMatchingPages(pages: [Page], pagesFromPageRenderer: MobileContentPageRenderer) -> [Page] {
            
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
    
    // MARK: - Page Navigation
    
    private func getInitialPageNavigation(pageRenderer: MobileContentPageRenderer) -> MobileContentPagesNavigationEvent? {
            
        guard let initialPage = getInitialPageModel(pageRenderer: pageRenderer) else {
            return nil
        }
        
        return getPageNavigationEvent(page: initialPage, animated: false)
    }
    
    private func checkIfEventIsPageListenerAndNavigate(eventId: EventId) -> Bool {
            
        let allPages: [Page] = currentPageRenderer.value.getAllPageModels()
        
        guard let pageListeningForEvent = allPages.first(where: {$0.listeners.contains(eventId)}) else {
            return false
        }
                
        navigateToPage(page: pageListeningForEvent, animated: true)
        
        return true
    }
    
    func navigateToPreviousPage(animated: Bool) {
        
        guard let page = getPage(index: currentRenderedPageNumber - 1) else {
            return
        }
        
        navigateToPage(page: page, animated: animated)
    }
    
    func navigateToNextPage(animated: Bool) {
        
        guard let page = getPage(index: currentRenderedPageNumber + 1) else {
            return
        }
        
        navigateToPage(page: page, animated: animated)
    }
        
    func navigateToPage(page: Page, animated: Bool) {
        
        let navigationEvent: MobileContentPagesNavigationEvent = getPageNavigationEvent(page: page, animated: animated)
        
        sendPageNavigationEvent(navigationEvent: navigationEvent)
    }
        
    func getPageNavigationEvent(page: Page, animated: Bool) -> MobileContentPagesNavigationEvent {
                
        let hiddenPages: [Page] = pageModels.filter({$0.isHidden})
        let hiddenPageIndexes: [Int] = hiddenPages.compactMap({pageModels.firstIndex(of: $0)})
        let visiblePages: [Page] = pageModels.filter({!$0.isHidden})
        
        let pageIndexToNavigateTo: Int
        let insertPages: [Int]?
        let deletePages: [Int]? = hiddenPageIndexes
        let setPages: [Page]?
        
        if let indexForExistingPageInStack = visiblePages.firstIndex(where: {$0.id == page.id}) {
            
            pageIndexToNavigateTo = indexForExistingPageInStack
            insertPages = nil
            setPages = visiblePages
        }
        else {
            
            let pagePosition: Int32 = page.position
            let lastPageIndex: Int = pageModels.count - 1
            
            var insertAtIndex: Int = lastPageIndex
            
            for index in 0 ..< visiblePages.count {
                
                let currentPagePosition: Int32 = visiblePages[index].position
                
                if currentPagePosition > pagePosition {
                    insertAtIndex = index
                    break
                }
                else if index == lastPageIndex {
                    insertAtIndex = lastPageIndex + 1
                }
            }
            
            var pagesWithNewPage: [Page] = visiblePages
            pagesWithNewPage.insert(page, at: insertAtIndex)

            pageIndexToNavigateTo = insertAtIndex
            insertPages = [insertAtIndex]
            setPages = pagesWithNewPage
        }
                
        return MobileContentPagesNavigationEvent(
            pageNavigation: PageNavigationCollectionViewNavigationModel(
                navigationDirection: nil,
                page: pageIndexToNavigateTo,
                animated: animated,
                reloadCollectionViewDataNeeded: false,
                insertPages: insertPages,
                deletePages: deletePages
            ),
            setPages: setPages,
            pagePositions: nil
        )
    }
    
    func sendPageNavigationEvent(navigationEvent: MobileContentPagesNavigationEvent) {
            
        if let pages = navigationEvent.setPages, pages.count > 0 {
            setPages(pages: pages)
        }
        
        pageNavigationEventSignal.accept(value: navigationEvent)
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
        
        if let currentPage = getPage(index: page) {
            
            updateCachedPageDataForPageChange(currentPage: currentPage)
        }
        
        currentRenderedPageNumber = page
        
        if page > highestPageNumberViewed {
            highestPageNumberViewed = page
        }
    }
    
    func pageDidDisappear(page: Int) {
                      
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
