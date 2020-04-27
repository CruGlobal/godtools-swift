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
    
    private var articleManifest: ArticleManifestXmlParser?
    
    private weak var flowDelegate: FlowDelegate?
    
    let godToolsResource: GodToolsResource
    let resourceLatestTranslationServices: ResourceLatestTranslationServices
    let categories: ObservableValue<[ArticleCategory]> = ObservableValue(value: [])
    let navTitle: ObservableValue<String> = ObservableValue(value: "")
    let isLoading: ObservableValue<Bool> = ObservableValue(value: false)
    
    required init(flowDelegate: FlowDelegate, resource: DownloadedResource, godToolsResource: GodToolsResource, resourceLatestTranslationServices: ResourceLatestTranslationServices, analytics: GodToolsAnaltyics) {
        
        self.flowDelegate = flowDelegate
        self.resource = resource
        self.godToolsResource = godToolsResource
        self.resourceLatestTranslationServices = resourceLatestTranslationServices
        self.analytics = analytics
                
        navTitle.accept(value: resource.name)
        
        reloadArticles(forceDownload: false)
    }
    
    deinit {
        resourceLatestTranslationServices.cancel()
    }
    
    private func reloadArticles(forceDownload: Bool) {
        
        isLoading.accept(value: true)
        
        resourceLatestTranslationServices.getManifestXmlData(godToolsResource: godToolsResource, forceDownload: forceDownload) { [weak self] (manifestXmlData: Data?, error: Error?) in
                            
            if let manifestXmlData = manifestXmlData {
                
                let articleManifest = ArticleManifestXmlParser(xmlData: manifestXmlData)
                
                self?.categories.accept(value: articleManifest.categories)
                self?.articleManifest = articleManifest
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
        
        if let articleManifest = articleManifest {
            flowDelegate?.navigate(step: .articleCategoryTappedFromArticleCategories(resource: resource, godToolsResource: godToolsResource, category: category, articleManifest: articleManifest))
        }
        else {
            // TODO: Show Error. ~Levi
            // There is no way for someone to move on to an article without the article manifest xml parser being created first because categories come from there.
        }
    }
}
