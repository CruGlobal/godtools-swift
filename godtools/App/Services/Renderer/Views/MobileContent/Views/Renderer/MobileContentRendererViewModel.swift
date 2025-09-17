//
//  MobileContentRendererViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 1/30/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import UIKit
import GodToolsToolParser
import Combine

class MobileContentRendererViewModel: MobileContentPagesViewModel {
    
    private let resourcesRepository: ResourcesRepository
    private let translationsRepository: TranslationsRepository
    private let mobileContentEventAnalytics: MobileContentRendererEventAnalyticsTracking
    private let getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase
    private let getTranslatedLanguageName: GetTranslatedLanguageName
    private let initialPage: MobileContentRendererInitialPage
    private let initialPageConfig: MobileContentRendererInitialPageConfig
    private let initialPageSubIndex: Int?
    private let initialSelectedLanguageIndex: Int
    
    private var languagelocaleIdUsed: Set<String> = Set()
    private var cancellables: Set<AnyCancellable> = Set()
    
    private(set) var renderer: CurrentValueSubject<MobileContentRenderer, Never>
    private(set) var currentPageRenderer: CurrentValueSubject<MobileContentPageRenderer, Never>
    private(set) var trainingTipsEnabled: Bool = false
    private(set) var toolSettingsObserver: ToolSettingsObserver?
        
    @Published private(set) var appLanguage: AppLanguageDomainModel = LanguageCodeDomainModel.english.rawValue
    @Published private(set) var languages: [LanguageDataModel] = Array()
    @Published private(set) var languageNames: [String] = Array()
    @Published private(set) var selectedLanguageIndex: Int
    
    let rendererWillChangeSignal: Signal = Signal()
    let incrementUserCounterUseCase: IncrementUserCounterUseCase
    
    init(renderer: MobileContentRenderer, initialPage: MobileContentRendererInitialPage?, initialPageConfig: MobileContentRendererInitialPageConfig?, initialPageSubIndex: Int?, resourcesRepository: ResourcesRepository, translationsRepository: TranslationsRepository, mobileContentEventAnalytics: MobileContentRendererEventAnalyticsTracking, getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase, getTranslatedLanguageName: GetTranslatedLanguageName, trainingTipsEnabled: Bool, incrementUserCounterUseCase: IncrementUserCounterUseCase, selectedLanguageIndex: Int?) {
        
        self.renderer = CurrentValueSubject(renderer)
        self.currentPageRenderer = CurrentValueSubject(renderer.pageRenderers[0])
        self.initialPage = initialPage ?? .pageNumber(value: 0)
        self.initialPageConfig = initialPageConfig ?? MobileContentRendererInitialPageConfig(shouldNavigateToStartPageIfLastPage: false, shouldNavigateToPreviousVisiblePageIfHiddenPage: false)
        self.initialPageSubIndex = initialPageSubIndex
        self.resourcesRepository = resourcesRepository
        self.translationsRepository = translationsRepository
        self.mobileContentEventAnalytics = mobileContentEventAnalytics
        self.getCurrentAppLanguageUseCase = getCurrentAppLanguageUseCase
        self.getTranslatedLanguageName = getTranslatedLanguageName
        self.trainingTipsEnabled = trainingTipsEnabled
        self.incrementUserCounterUseCase = incrementUserCounterUseCase
        self.initialSelectedLanguageIndex = selectedLanguageIndex ?? 0
        self.selectedLanguageIndex = initialSelectedLanguageIndex
                
        super.init()
        
        getCurrentAppLanguageUseCase
            .getLanguagePublisher()
            .receive(on: DispatchQueue.main)
            .assign(to: &$appLanguage)
        
        Publishers.CombineLatest(
            $languages,
            $appLanguage.dropFirst()
        )
        .receive(on: DispatchQueue.main)
        .sink { [weak self] (languages: [LanguageDataModel], appLanguage: AppLanguageDomainModel) in
            
            self?.languageNames = languages.map({ (language: LanguageDataModel) in
                getTranslatedLanguageName.getLanguageName(language: language, translatedInLanguage: appLanguage)
            })
        }
        .store(in: &cancellables)
              
        resourcesRepository.observeDatabaseChangesPublisher()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.updateTranslationsIfNeeded()
            }
            .store(in: &cancellables)
        
        countLanguageUsage(localeId: currentPageRenderer.value.language.localeId)
    }
    
    var resource: ResourceDataModel {
        return renderer.value.resource
    }
    
    func getSelectedLanguage() -> LanguageDataModel? {
        
        guard selectedLanguageIndex >= 0 && selectedLanguageIndex < languages.count else {
            return nil
        }
        
        return languages[selectedLanguageIndex]
    }
    
    override func viewDidFinishLayout(window: UIViewController, safeArea: UIEdgeInsets) {
        
        super.viewDidFinishLayout(window: window, safeArea: safeArea)
        
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
    
    override func pageDidReceiveEvent(eventId: EventId) -> ProcessedEventResult? {
                
        trackContentEvent(eventId: eventId)
        
        let currentPageRenderer: MobileContentPageRenderer = currentPageRenderer.value
        
        _ = super.checkEventForPageListenerAndNavigate(
            listeningPages: currentPageRenderer.getAllPageModels(),
            eventId: eventId
        )
        
        if currentPageRenderer.manifest.dismissListeners.contains(eventId) {
           
            handleDismissToolEvent()
        }
                
        return nil
    }
    
    func setTrainingTipsEnabled(enabled: Bool) {
        
        guard trainingTipsEnabled != enabled else {
            return
        }
        
        trainingTipsEnabled = enabled
        
        setPageRenderer(pageRenderer: currentPageRenderer.value, navigationEvent: nil, pagePositions: nil)
    }
    
    func createToolSettingsLanguages() -> ToolSettingsLanguages {
        return ToolSettingsLanguages(
            primaryLanguageId: languages[0].id,
            parallelLanguageId: languages[safe: 1]?.id,
            selectedLanguageId: languages[selectedLanguageIndex].id
        )
    }
    
    func createToolSettingsObserver(with toolSettingsLanguages: ToolSettingsLanguages) -> ToolSettingsObserver {
        let toolSettingsObserver = ToolSettingsObserver(
            toolId: renderer.value.resource.id,
            languages: toolSettingsLanguages,
            pageNumber: currentPageNumber,
            trainingTipsEnabled: trainingTipsEnabled
        )
        
        return toolSettingsObserver
    }
    
    func attachObserversForToolSettings(_ toolSettingsObserver: ToolSettingsObserver) -> ToolSettingsObserver {
        toolSettingsObserver.$languages
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (languages: ToolSettingsLanguages) in
                
                self?.setRendererPrimaryLanguage(
                    primaryLanguageId: languages.primaryLanguageId,
                    parallelLanguageId: languages.parallelLanguageId,
                    selectedLanguageId: languages.selectedLanguageId
                )
            }
            .store(in: &cancellables)
        
        toolSettingsObserver.$trainingTipsEnabled
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (trainingTipsEnabled: Bool) in
                
                self?.setTrainingTipsEnabled(enabled: trainingTipsEnabled)
            }
            .store(in: &cancellables)
        
        return toolSettingsObserver
    }
    
    func setUpToolSettingsObserver() -> ToolSettingsObserver {
        
        let languages = createToolSettingsLanguages()
        
        let toolSettingsObserver = attachObserversForToolSettings(createToolSettingsObserver(with: languages))
        self.toolSettingsObserver = toolSettingsObserver
        
        return toolSettingsObserver
    }
    
    // MARK: - Renderer / Page Renderer
    
    var primaryPageRenderer: MobileContentPageRenderer {
        return renderer.value.pageRenderers[0]
    }
    
    override var layoutDirection: UISemanticContentAttribute {
        return UISemanticContentAttribute.from(languageDirection: renderer.value.languages.primaryLanguage.languageDirectionDomainModel)
    }
    
    func setRendererPrimaryLanguage(primaryLanguageId: String, parallelLanguageId: String?, selectedLanguageId: String?) {
        
        let appLanguage: AppLanguageDomainModel = self.appLanguage
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
                
            case .failure(let error):
                
                currentRenderer.navigation.presentError(error: error, appLanguage: appLanguage)
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

        let pageModels: [Page]
        
        if isInitialPageRender {
            
            pageModels = getInitialPages(pageRenderer: pageRenderer, initialPage: initialPage)
        }
        else {
            
            pageModels = getPagesFromPageRendererMatchingPages(pages: getPages(), pagesFromPageRenderer: pageRenderer)
        }
        
        super.setPages(pages: pageModels)
        
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
                    page: currentPageNumber,
                    animated: false,
                    reloadCollectionViewDataNeeded: true,
                    insertPages: nil,
                    deletePages: nil
                ),
                setPages: nil,
                pagePositions: pagePositions,
                parentPageParams: nil,
                pageSubIndex: nil
            )
        }
        
        let pageSubIndex: Int? = isInitialPageRender ? initialPageSubIndex : navigationEventToSend.pageSubIndex
        
        let pageNavigationForLanguageDirection = navigationEventToSend.pageNavigation.copy(navigationDirection: layoutDirection)
        
        let eventWithCorrectLanguageDirection = MobileContentPagesNavigationEvent(
            pageNavigation: pageNavigationForLanguageDirection,
            setPages: navigationEventToSend.setPages,
            pagePositions: navigationEventToSend.pagePositions,
            parentPageParams: navigationEventToSend.parentPageParams,
            pageSubIndex: pageSubIndex
        )
        
        super.sendPageNavigationEvent(navigationEvent: eventWithCorrectLanguageDirection)
        
        let pageRenderers: [MobileContentPageRenderer] = renderer.value.pageRenderers
        let pageRendererIndex: Int = pageRenderers.firstIndex(where: { $0.language.id == pageRenderer.language.id }) ?? 0
        
        selectedLanguageIndex = pageRendererIndex
    }
    
    private func getInitialPageModel(pageRenderer: MobileContentPageRenderer) -> Page? {
        
        let allPages: [Page] = pageRenderer.getAllPageModels()
        
        var page: Page?
        switch initialPage {
        
        case .pageId(let value):
            page = allPages.first(where: {$0.id == value})
            
        case .pageNumber(let value):
            
            if value >= 0 && value < allPages.count {
                page = allPages[value]
            } else {
                page = nil
            }
        }
        
        guard page != nil else {
            return page
        }
        
        if initialPageConfig.shouldNavigateToPreviousVisiblePageIfHiddenPage {
            page = getPreviousVisiblePageIfHidden(page: page)
        }
        
        if initialPageConfig.shouldNavigateToStartPageIfLastPage {
            page = getStartPageIfLastPage(page: page, pageRenderer: pageRenderer)
        }
        
        return page
    }
    
    private func getPreviousVisiblePageIfHidden(page: Page?) -> Page? {
        var page = page
        
        while(page?.isHidden == true) {
            page = page?.previousPage
        }
        
        return page
    }
    
    private func getStartPageIfLastPage(page: Page?, pageRenderer: MobileContentPageRenderer) -> Page? {
        var page = page
        let visiblePages = pageRenderer.getVisiblePageModels()
        
        if page?.id == visiblePages.last?.id {
            page = visiblePages.first
        }
        
        return page
    }
    
    func getInitialPages(pageRenderer: MobileContentPageRenderer, initialPage: MobileContentRendererInitialPage) -> [Page] {
            
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
    
    func getPagesWalkingUpParent(fromPage: Page, pagesFromPageRenderer: MobileContentPageRenderer, includeFromPage: Bool = true) -> [Page] {
        
        let allPages: [Page] = pagesFromPageRenderer.getAllPageModels()
        
        var pages: [Page] = Array()
        
        if includeFromPage {
            pages.append(fromPage)
        }
        
        var nextParentPage: Page? = fromPage.parentPage
        
        while let parentPage = nextParentPage {
            pages.insert(parentPage, at: 0)
            nextParentPage = parentPage.parentPage
        }
        
        return pages
    }
    
    // MARK: - Page Navigation
    
    private func getInitialPageNavigation(pageRenderer: MobileContentPageRenderer) -> MobileContentPagesNavigationEvent? {
            
        guard let initialPage = getInitialPageModel(pageRenderer: pageRenderer) else {
            return nil
        }
        
        return getPageNavigationEvent(page: initialPage, animated: false, reloadCollectionViewDataNeeded: true)
    }
    
    func configureRendererPageContextUserInfo(userInfo: inout [String: Any], page: Int) {
        // Subclasses can override to attach additional info.
    }
    
    // MARK: - Page Life Cycle
    
    override func pageWillAppear(page: Int, pageParams: MobileContentPageWillAppearParams) -> MobileContentView? {
                
        _ = super.pageWillAppear(page: page, pageParams: pageParams)
        
        guard let window = self.window, let safeArea = self.safeArea else {
            return nil
        }
        
        guard page >= 0 && page < pageModels.count else {
            return nil
        }
        
        var userInfo: [String: Any] = Dictionary()
        
        configureRendererPageContextUserInfo(userInfo: &userInfo, page: page)
                
        let renderPageResult: Result<MobileContentView, Error> = currentPageRenderer.value.renderPageModel(
            pageModel: pageModels[page],
            page: page,
            numberOfPages: pageModels.count,
            parentPageParams: pageParams.parentPageParams,
            window: window,
            safeArea: safeArea,
            trainingTipsEnabled: trainingTipsEnabled,
            userInfo: userInfo
        )
        
        switch renderPageResult {
        
        case .success(let mobileContentView):
            return mobileContentView
            
        case .failure( _):
            break
        }
        
        return nil
    }
    
    override func pageDidAppear(page: Int) {
        
        if let currentPage = getPage(index: page) {
            
            updateCachedPageDataForPageChange(currentPage: currentPage)
        }
        
        super.pageDidAppear(page: page)
    }
    
    override func pageDidDisappear(page: Int) {
             
        super.pageDidDisappear(page: page)
    }
    
    override func didChangeMostVisiblePage(page: Int) {
        
        super.didChangeMostVisiblePage(page: page)
    }
    
    override func didScrollToPage(page: Int) {
        
        super.didScrollToPage(page: page)
        
        removeHiddenPages()
    }
    
    private func removeHiddenPages() {
        
        let currentRenderedPages: [Page] = pageModels
        let currentPageIndex: Int = currentPageNumber
        
        let currentRenderedHiddenPages: [Page] = currentRenderedPages.filter({$0.isHidden})
        let onlyHiddenPageIsCurrentPage: Bool = currentRenderedHiddenPages.count == 1 && currentRenderedPages[currentPageIndex].isHidden
        
        let hasHiddenPagesToRemove: Bool = currentRenderedHiddenPages.count > 0 && !onlyHiddenPageIsCurrentPage
        
        guard hasHiddenPagesToRemove else {
            return
        }
        
        var visiblePages: [Page] = Array()
        var deletePagesAtIndexes: [Int] = Array()
        
        var currentPageIndexOffsetForHiddenPagesRemoved: Int = 0
        
        for pageIndex in 0 ..< currentRenderedPages.count {
            
            let page: Page = currentRenderedPages[pageIndex]
            
            if page.isHidden && pageIndex < currentPageIndex {
                currentPageIndexOffsetForHiddenPagesRemoved += 1
            }
            
            if !page.isHidden || page.isHidden && pageIndex == currentPageIndex {
                visiblePages.append(page)
            }
            else {
                deletePagesAtIndexes.append(pageIndex)
            }
        }
                
        var navigateToPage: Int = currentPageIndex - currentPageIndexOffsetForHiddenPagesRemoved
        if navigateToPage < 0 {
            navigateToPage = 0
        }
        
        let event = MobileContentPagesNavigationEvent(
            pageNavigation: PageNavigationCollectionViewNavigationModel(
                navigationDirection: nil,
                page: navigateToPage,
                animated: false,
                reloadCollectionViewDataNeeded: false,
                insertPages: nil,
                deletePages: deletePagesAtIndexes
            ),
            setPages: visiblePages,
            pagePositions: nil,
            parentPageParams: nil,
            pageSubIndex: nil
        )
        
        sendPageNavigationEvent(navigationEvent: event)
    }
}

// MARK: - Pages Data Cache

extension MobileContentRendererViewModel {
    
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

extension MobileContentRendererViewModel {
    
    private func updateTranslationsIfNeeded() {
        
        var translationsNeededDownloading: [TranslationDataModel] = Array()
                
        for pageRenderer in renderer.value.pageRenderers {
            
            let resource: ResourceDataModel = pageRenderer.resource
            let language: LanguageDataModel = pageRenderer.language
            let currentTranslation: TranslationDataModel = pageRenderer.translation
            
            guard let latestTranslation = translationsRepository.getCachedLatestTranslation(resourceId: resource.id, languageId: language.id) else {
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
        
        translationsRepository.getTranslationManifestsFromRemote(translations: translationsNeededDownloading, manifestParserType: .renderer, requestPriority: .high, includeRelatedFiles: true, shouldFallbackToLatestDownloadedTranslationIfRemoteFails: false)
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
                    
                    let resource: ResourceDataModel = pageRenderer.resource
                    let language: LanguageDataModel = pageRenderer.language
                    let currentTranslation: TranslationDataModel = pageRenderer.translation
                    
                    let updatedManifest: Manifest
                    let updatedTranslation: TranslationDataModel
                    
                    if let latestTranslation = self?.translationsRepository.getCachedLatestTranslation(resourceId: resource.id, languageId: language.id), latestTranslation.version > currentTranslation.version, let manifestFileDataModel = manifestFileDataModels.filter({$0.translation.id == latestTranslation.id}).first {
                        
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
                
        mobileContentEventAnalytics.trackContentEvent(
            eventId: eventId,
            resource: resource,
            appLanguage: renderer.value.appLanguage,
            languages: renderer.value.languages
        )
    }
    
    private func countLanguageUsageIfLanguageChanged(updatedLanguage: LanguageDataModel) {
        
        let updatedLocaleId = updatedLanguage.localeId
        let languageChanged: Bool = currentPageRenderer.value.language.localeId != updatedLocaleId
        
        if languageChanged {
            
            countLanguageUsage(localeId: updatedLocaleId)
        }
    }
    
    private func countLanguageUsage(localeId: String) {
        
        if languageUsageAlreadyCountedThisSession(localeId: localeId) {
            return
        }
        
        let locale = Locale(identifier: localeId)
        
        incrementUserCounterUseCase.incrementUserCounter(for: .languageUsed(locale: locale))
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                
                switch completion {
                case .finished:
                    self?.trackLanguageUsageCountedThisSession(localeId: localeId)
                    
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
            .receive(on: DispatchQueue.main)
            .sink { _ in
                
            } receiveValue: { _ in
                
            }
            .store(in: &cancellables)
    }
    
    private func trackLanguageUsageCountedThisSession(localeId: String) {
        languagelocaleIdUsed.insert(localeId)
    }
}
