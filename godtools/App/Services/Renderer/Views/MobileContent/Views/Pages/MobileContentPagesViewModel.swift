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
    private let startingPage: Int?
    
    private var safeArea: UIEdgeInsets?
    private var pageModels: [Page] = Array()
    private var languagelocaleIdUsed: Set<String> = Set()
    private var cancellables: Set<AnyCancellable> = Set()
    
    private(set) var renderer: CurrentValueSubject<MobileContentRenderer, Never>
    private(set) var currentPageRenderer: CurrentValueSubject<MobileContentPageRenderer, Never>
    private(set) var currentPage: Int = 0
    private(set) var highestPageNumberViewed: Int = 0
    private(set) var trainingTipsEnabled: Bool = false
    
    private(set) weak var window: UIViewController?
    
    let numberOfPages: ObservableValue<Int> = ObservableValue(value: 0)
    let pageNavigationSemanticContentAttribute: ObservableValue<UISemanticContentAttribute>
    let rendererWillChangeSignal: Signal = Signal()
    let pageNavigation: ObservableValue<MobileContentPagesNavigationModel?> = ObservableValue(value: nil)
    let pagesRemoved: ObservableValue<[IndexPath]> = ObservableValue(value: [])
    let incrementUserCounterUseCase: IncrementUserCounterUseCase
    
    init(renderer: MobileContentRenderer, page: Int?, resourcesRepository: ResourcesRepository, translationsRepository: TranslationsRepository, mobileContentEventAnalytics: MobileContentEventAnalyticsTracking, initialPageRenderingType: MobileContentPagesInitialPageRenderingType, trainingTipsEnabled: Bool, incrementUserCounterUseCase: IncrementUserCounterUseCase) {
        
        self.renderer = CurrentValueSubject(renderer)
        self.currentPageRenderer = CurrentValueSubject(renderer.pageRenderers[0])
        self.startingPage = page
        self.resourcesRepository = resourcesRepository
        self.translationsRepository = translationsRepository
        self.mobileContentEventAnalytics = mobileContentEventAnalytics
        self.initialPageRenderingType = initialPageRenderingType
        self.trainingTipsEnabled = trainingTipsEnabled
        self.incrementUserCounterUseCase = incrementUserCounterUseCase
        
        pageNavigationSemanticContentAttribute = ObservableValue(value: UISemanticContentAttribute.from(languageDirection: renderer.primaryLanguage.direction))
        
        super.init()
        
        if let page = page {
            currentPage = page
        }
                
        resourcesRepository.getResourcesChanged()
            .receiveOnMain()
            .sink { [weak self] _ in
                self?.updateTranslationsIfNeeded()
            }
            .store(in: &cancellables)
        
        countLanguageUsage(localeId: currentPageRenderer.value.language.localeIdentifier)
    }
    
    deinit {

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
        
        let nextPage: Int = currentPage + 1
        
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
    
    private func didReceivePageListenerForPage(page: Int, pageModel: Page) {
        
        let isChooseYourOwnAdventure: Bool = initialPageRenderingType == .chooseYourOwnAdventure
        
        let pageNumber: Int
        let willReloadData: Bool
        
        if let pageNumberExistsInActivatePages = getIndexForFirstPageModel(pageModel: pageModel) {
            
            pageNumber = pageNumberExistsInActivatePages
            willReloadData = false
        }
        else if pageModel.isHidden || isChooseYourOwnAdventure {
            
            let insertAtPage: Int = currentPage + 1
            
            if insertAtPage < pageModels.count {
                
                pageModels.insert(pageModel, at: insertAtPage)
                pageNumber = insertAtPage
            }
            else {
                pageModels.append(pageModel)
                pageNumber = pageModels.count - 1
            }
            
            willReloadData = true
        }
        else {
            
            pageNumber = page
            willReloadData = false
        }
        
        let pageNavigationForReceivedPageListener = MobileContentPagesNavigationModel(
            willReloadData: willReloadData,
            page: pageNumber,
            pagePositions: nil,
            animated: true
        )
        
        pageNavigation.accept(value: pageNavigationForReceivedPageListener)
        
        if willReloadData {
            numberOfPages.accept(value: pageModels.count)
        }
    }
    
    var primaryPageRenderer: MobileContentPageRenderer {
        return renderer.value.pageRenderers[0]
    }
    
    var resource: ResourceModel {
        return renderer.value.resource
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
    
    func handleDismissToolEvent() {
        
        let event = DismissToolEvent(
            resource: resource,
            highestPageNumberViewed: highestPageNumberViewed
        )
        
        renderer.value.navigation.dismissTool(event: event)
    }
    
    func setTrainingTipsEnabled(enabled: Bool) {
        
        guard trainingTipsEnabled != enabled else {
            return
        }
        
        trainingTipsEnabled = enabled
        
        setPageRenderer(pageRenderer: currentPageRenderer.value)
    }
    
    func viewDidFinishLayout(window: UIViewController, safeArea: UIEdgeInsets) {
        
        self.window = window
        self.safeArea = safeArea
        
        guard let pageRenderer = renderer.value.pageRenderers.first else {
            return
        }
        
        if let startingPage = startingPage {
            
            let navigationModel = MobileContentPagesNavigationModel(
                willReloadData: true,
                page: startingPage,
                pagePositions: nil,
                animated: false
            )
            
            pageNavigation.accept(value: navigationModel)
        }
        
        setPageRenderer(pageRenderer: pageRenderer)
    }
    
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
        
        currentPage = page
        
        if page > highestPageNumberViewed {
            highestPageNumberViewed = page
        }
    }
    
    func pageDidDisappear(page: Int) {
              
        let didNavigateBack: Bool = currentPage < page
        let shouldRemoveAllFollowingPages: Bool = initialPageRenderingType == .chooseYourOwnAdventure && didNavigateBack
        
        if shouldRemoveAllFollowingPages {
            removeFollowingPagesFromPage(page: currentPage)
        }
        
        removePageIfHidden(page: page)
    }
    
    
    func pageDidReceiveEvent(eventId: EventId) -> ProcessedEventResult? {
        
        trackContentEvent(eventId: eventId)
        
        let currentPageRenderer: MobileContentPageRenderer = currentPageRenderer.value
        
        if currentPageRenderer.manifest.dismissListeners.contains(eventId) {
            handleDismissToolEvent()
        }
                                
        if let didReceivePageListenerForPageNumber = currentPageRenderer.getPageForListenerEvents(eventIds: [eventId]),
           let didReceivePageListenerEventForPageModel = currentPageRenderer.getPageModel(page: didReceivePageListenerForPageNumber)  {
            
            didReceivePageListenerForPage(
                page: didReceivePageListenerForPageNumber,
                pageModel: didReceivePageListenerEventForPageModel
            )
        }
        
        return nil
    }
    
    func didChangeMostVisiblePage(page: Int) {
        
        currentPage = page
    }
}
