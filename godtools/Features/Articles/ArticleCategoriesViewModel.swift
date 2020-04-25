//
//  ArticleCategoriesViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 4/14/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import RealmSwift

class ArticleCategoriesViewModel: ArticleCategoriesViewModelType {
    
    private let resource: DownloadedResource
    private let analytics: GodToolsAnaltyics
    
    private var articleManifestXmlParser: ArticleManifestXmlParser?
    
    private weak var flowDelegate: FlowDelegate?
    
    let godToolsResource: GodToolsResource
    let resourceLatestTranslationServices: ResourceLatestTranslationServices
    let articleAemImportService: ArticleAemImportService
    let categories: ObservableValue<[ArticleCategory]> = ObservableValue(value: [])
    let navTitle: ObservableValue<String> = ObservableValue(value: "")
    let isLoading: ObservableValue<Bool> = ObservableValue(value: false)
    
    required init(flowDelegate: FlowDelegate, resource: DownloadedResource, godToolsResource: GodToolsResource, resourceLatestTranslationServices: ResourceLatestTranslationServices, articleAemImportService: ArticleAemImportService, analytics: GodToolsAnaltyics) {
        
        self.flowDelegate = flowDelegate
        self.resource = resource
        self.godToolsResource = godToolsResource
        self.resourceLatestTranslationServices = resourceLatestTranslationServices
        self.articleAemImportService = articleAemImportService
        self.analytics = analytics
                
        navTitle.accept(value: resource.name)
        
        reloadArticles(forceDownload: false)
    }
    
    deinit {
        resourceLatestTranslationServices.cancelOperations()
    }
    
    private func reloadArticles(forceDownload: Bool) {
        
        isLoading.accept(value: true)
        
        resourceLatestTranslationServices.getManifestXmlData(forceDownload: forceDownload) { [weak self] (manifestXmlData: Data?, error: Error?) in
                            
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
            flowDelegate?.navigate(step: .articleCategoryTappedFromArticleCategories(resource: resource, godToolsResource: godToolsResource, category: category, articleManifest: articleManifestXmlParser))
        }
        else {
            // TODO: Show Error. ~Levi
            // There is no way for someone to move on to an article without the article manifest xml parser being created first because categories come from there.
        }
    }
}
