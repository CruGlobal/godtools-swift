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
    private let initialPage: MobileContentPagesPage?
    
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
    
    let numberOfPages: ObservableValue<Int> = ObservableValue(value: 0)
    let pageNavigationSemanticContentAttribute: ObservableValue<UISemanticContentAttribute>
    let rendererWillChangeSignal: Signal = Signal()
    let pageNavigation: ObservableValue<MobileContentPagesNavigationModel?> = ObservableValue(value: nil)
    let pagesRemoved: ObservableValue<[IndexPath]> = ObservableValue(value: [])
    let incrementUserCounterUseCase: IncrementUserCounterUseCase
    
    init(renderer: MobileContentRenderer, initialPage: MobileContentPagesPage?, resourcesRepository: ResourcesRepository, translationsRepository: TranslationsRepository, mobileContentEventAnalytics: MobileContentEventAnalyticsTracking, initialPageRenderingType: MobileContentPagesInitialPageRenderingType, trainingTipsEnabled: Bool, incrementUserCounterUseCase: IncrementUserCounterUseCase) {
        
        self.renderer = CurrentValueSubject(renderer)
        self.currentPageRenderer = CurrentValueSubject(renderer.pageRenderers[0])
        self.initialPage = initialPage
        self.resourcesRepository = resourcesRepository
        self.translationsRepository = translationsRepository
        self.mobileContentEventAnalytics = mobileContentEventAnalytics
        self.initialPageRenderingType = initialPageRenderingType
        self.trainingTipsEnabled = trainingTipsEnabled
        self.incrementUserCounterUseCase = incrementUserCounterUseCase
        
        pageNavigationSemanticContentAttribute = ObservableValue(value: UISemanticContentAttribute.from(languageDirection: renderer.primaryLanguage.direction))
        
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
        
        guard let pageRenderer = renderer.value.pageRenderers.first else {
            return
        }
        
        setPageRenderer(pageRenderer: pageRenderer)
        
        if let initialPage = self.initialPage {
            
            navigateToPage(
                page: initialPage,
                forceReloadPagesUI: false,
                animated: false
            )
        }
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
            
            navigateToPage(
                page: .pageNumber(value: didReceivePageListenerForPageNumber),
                forceReloadPagesUI: false,
                animated: true
            )
        }
        
        return nil
    }
    
    func setTrainingTipsEnabled(enabled: Bool) {
        
        guard trainingTipsEnabled != enabled else {
            return
        }
        
        trainingTipsEnabled = enabled
        
        setPageRenderer(pageRenderer: currentPageRenderer.value)
    }
    
    // MARK: - Renderer / Page Renderer
    
    var primaryPageRenderer: MobileContentPageRenderer {
        return renderer.value.pageRenderers[0]
    }
    
    func setRenderer(renderer: MobileContentRenderer, pageRendererIndex: Int?) {
            
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
        
        pageNavigationSemanticContentAttribute.accept(value: UISemanticContentAttribute.from(languageDirection: renderer.primaryLanguage.direction))
        
        setPageRenderer(pageRenderer: pageRenderer)
    }
    
    func setPageRenderer(pageRenderer: MobileContentPageRenderer) {
        
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
            
            if newPageModelsToRenderer.isEmpty && pageRenderer.getRenderablePageModels().count > 0 {
                
                newPageModelsToRenderer = [pageRenderer.getRenderablePageModels()[0]]
            }

            pageModelsToRender = newPageModelsToRenderer
            
        case .visiblePages:
            
            pageModelsToRender = pageRenderer.getVisibleRenderablePageModels()
        }
        
        rendererWillChangeSignal.accept()
        
        currentPageRenderer.send(pageRenderer)
                
        self.pageModels = pageModelsToRender
        
        numberOfPages.accept(value: pageModels.count)
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
    
    private func navigateToPage(page: MobileContentPagesPage, forceReloadPagesUI: Bool, animated: Bool) {
        
        let isChooseYourOwnAdventure: Bool = initialPageRenderingType == .chooseYourOwnAdventure
        let pageRenderer: MobileContentPageRenderer = currentPageRenderer.value
        let renderablePages: [Page] = pageRenderer.getRenderablePageModels()
        
        let pagesToRender: [Page]?
        let navigateToPageModel: Page?
        let shouldReloadPagesUI: Bool
        
        switch page {
            
        case .pageId(let value):
                     
            if isChooseYourOwnAdventure {
                
                let introPageId: String = "intro"
                let categoriesPageId: String = "categories"
                
                guard value != categoriesPageId && value != introPageId else {
                    return
                }
                
                guard let pageModelMatchingPageId = renderablePages.first(where: {$0.id == value}) else {
                    return
                }
                
                if let introPage = renderablePages.first(where: {$0.id == introPageId}),
                   let categoriesPage = renderablePages.first(where: {$0.id == categoriesPageId}) {
                    
                    pagesToRender = [introPage, categoriesPage, pageModelMatchingPageId]
                }
                else {
                    
                    pagesToRender = [pageModelMatchingPageId]
                }
                
                navigateToPageModel = pageModelMatchingPageId
                shouldReloadPagesUI = true
            }
            else {
                
                var pageModelsToRenderUpToPageToNavigateTo: [Page] = Array()
                var pageModelMatchingPageId: Page?
                
                for pageModel in renderablePages {
                    
                    pageModelsToRenderUpToPageToNavigateTo.append(pageModel)
                    
                    if pageModel.id == value {
                        pageModelMatchingPageId = pageModel
                        break
                    }
                }
                
                pagesToRender = pageModelsToRenderUpToPageToNavigateTo
                navigateToPageModel = pageModelMatchingPageId
                shouldReloadPagesUI = true
            }
            
        case .pageNumber(let value):
                        
            if value >= 0 && value < renderablePages.count {
                navigateToPageModel = renderablePages[value]
            }
            else {
                navigateToPageModel = nil
            }

            guard let navigateToPageModel = navigateToPageModel else {
                return
            }
            
            let isHiddenPage: Bool = navigateToPageModel.isHidden
            
            if isHiddenPage || isChooseYourOwnAdventure {
                
                let insertAtPage: Int = currentRenderedPageNumber + 1
                
                var pageModelsToRenderUpToPageToNavigateTo: [Page] = pageModels
                
                if insertAtPage < pageModels.count {
                    
                    pageModelsToRenderUpToPageToNavigateTo.insert(navigateToPageModel, at: insertAtPage)
                }
                else {
                    pageModelsToRenderUpToPageToNavigateTo.append(navigateToPageModel)
                }
                
                pagesToRender = pageModelsToRenderUpToPageToNavigateTo
                shouldReloadPagesUI = true
            }
            else {
                
                pagesToRender = renderablePages
                shouldReloadPagesUI = false
            }
        }
        
        guard let pagesToRender = pagesToRender else {
            return
        }
        
        pageModels = pagesToRender
        
        guard let navigateToPageModel = navigateToPageModel else {
            return
        }
        
        guard let navigateToPageNumber = pageModels.firstIndex(of: navigateToPageModel) else {
            return
        }
        
        let willReloadData: Bool = shouldReloadPagesUI || forceReloadPagesUI
                
        let pageNavigationForReceivedPageListener = MobileContentPagesNavigationModel(
            willReloadData: willReloadData,
            page: navigateToPageNumber,
            pagePositions: nil,
            animated: animated
        )
        
        pageNavigation.accept(value: pageNavigationForReceivedPageListener)
        
        if willReloadData {
            numberOfPages.accept(value: pageModels.count)
        }
    }
}

// MARK: - Private

extension MobileContentPagesViewModel {
    
    private var initialPageNumber: Int? {
        
        guard let initialPage = self.initialPage else {
            return nil
        }
        
        let pageModels: [Page] = currentPageRenderer.value.getRenderablePageModels()
        
        let pageNumber: Int?
        
        switch initialPage {
            
        case .pageNumber(let value):
            
            pageNumber = value
            
        case .pageId(let value):
            
            guard let pageModel = pageModels.filter({$0.id == value}).first else {
                return nil
            }
            
            pageNumber = Int(pageModel.position)
        }
        
        guard let pageNumber = pageNumber else {
            return nil
        }
        
        guard pageNumber >= 0 && pageNumber < pageModels.count else {
            return nil
        }
        
        return pageNumber
    }
    
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
                
                self?.setRenderer(renderer: updatedRenderer, pageRendererIndex: pageRendererIndex)
            }
            .store(in: &cancellables)
    }
    
    private func getRendererPageModelsMatchingCurrentRenderedPageModels(pageRenderer: MobileContentPageRenderer) -> [Page] {
        
        var rendererPageModelsMatchingCurrentRenderedPageModels: [Page] = Array()
        
        let currentRenderedPageModels: [Page] = pageModels
        let allPageModelsInNewRenderer: [Page] = pageRenderer.getRenderablePageModels()
        
        for pageModel in currentRenderedPageModels {
                        
            guard let setRendererPageModel = allPageModelsInNewRenderer.filter({$0.id == pageModel.id}).first else {
                continue
            }
            
            rendererPageModelsMatchingCurrentRenderedPageModels.append(setRendererPageModel)
        }
        
        return rendererPageModelsMatchingCurrentRenderedPageModels
    }
    
    private func getIndexForFirstPageModel(pageModel: Page) -> Int? {
        for index in 0 ..< pageModels.count {
            let activePageModel: Page = pageModels[index]
            if activePageModel.id == pageModel.id {
                return index
            }
        }
        return nil
    }
    
    private func removePage(page: Int) {
        
        let pageIsInArrayBounds: Bool = page >= 0 && page < pageModels.count
        
        guard pageIsInArrayBounds else {
            return
        }
        
        pageModels.remove(at: page)
        numberOfPages.setValue(value: pageModels.count)
        pagesRemoved.accept(value: [IndexPath(item: page, section: 0)])
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
