//
//  ArticleCategoriesViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 4/14/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class ArticleCategoriesViewModel: ArticleCategoriesViewModelType {
    
    private let resource: DownloadedResource
    private let language: Language
    private let getResourceLatestTranslationServices: GetResourceLatestTranslationServices
    private let analytics: GodToolsAnaltyics
    
    private var articleManifestXmlParser: ArticleManifestXmlParser?
    
    private weak var flowDelegate: FlowDelegate?
    
    let categories: ObservableValue<[ArticleCategory]> = ObservableValue(value: [])
    let navTitle: ObservableValue<String> = ObservableValue(value: "")
    let isLoading: ObservableValue<Bool> = ObservableValue(value: false)
    
    required init(flowDelegate: FlowDelegate, resource: DownloadedResource, language: Language, getResourceLatestTranslationServices: GetResourceLatestTranslationServices, analytics: GodToolsAnaltyics) {
        
        self.flowDelegate = flowDelegate
        self.resource = resource
        self.language = language
        self.getResourceLatestTranslationServices = getResourceLatestTranslationServices
        self.analytics = analytics
        
        navTitle.accept(value: resource.name)
        
        reloadArticles(forceDownload: false)
    }
    
    deinit {
        getResourceLatestTranslationServices.cancelGetManifestXmlData()
    }
    
    var resourceLanguageTranslationFilesCache: ResourceLanguageTranslationFilesCache {
        return ResourceLanguageTranslationFilesCache(resource: resource, language: language, cache: getResourceLatestTranslationServices.cache)
    }
    
    private func reloadArticles(forceDownload: Bool) {
        
        guard let translation = resource.getTranslationForLanguage(language) else {
            // TODO: Should report error if translation could not be found.
            // TODO: Would like to add service that based on the resource and chosen laungage, fetch the latest translation to use.
            return
        }
        
        isLoading.accept(value: true)
        
        getResourceLatestTranslationServices.getManifestXmlData(resource: resource, language: language, translation: translation, forceDownload: forceDownload) { [weak self] (manifestXmlData: Data?, error: Error?) in
                            
            if let manifestXmlData = manifestXmlData {
                let articleManifestXmlParser = ArticleManifestXmlParser(xmlData: manifestXmlData)
                self?.categories.accept(value: articleManifestXmlParser.categories)
                self?.articleManifestXmlParser = articleManifestXmlParser
                self?.isLoading.accept(value: false)
            }
            else if let error = error {
                // TODO: Handle error. ~Levi
                print("\n ERROR: \(error)")
            }
            else {
                // TODO: Handle no data. ~Levi
            }
        }
    }
    
    func pageViewed() {
        analytics.recordScreenView(screenName: "Categories", siteSection: resource.code, siteSubSection: "")
    }
    
    func refreshArticles() {
        reloadArticles(forceDownload: true)
    }
    
    func articleTapped(category: ArticleCategory) {
        
        if let articleManifestXmlParser = articleManifestXmlParser {
            flowDelegate?.navigate(step: .articleCategoryTappedFromArticleCategories(category: category, resource: resource, articleManifest: articleManifestXmlParser))
        }
        else {
            // TODO: Show Error. ~Levi
            // There is no way for someone to move on to an article without the article manifest xml parser being created first because categories come from there.
        }
    }
}
