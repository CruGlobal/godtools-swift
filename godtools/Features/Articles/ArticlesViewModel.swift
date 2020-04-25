//
//  ArticlesViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 4/21/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class ArticlesViewModel: ArticlesViewModelType {
    
    private let resource: DownloadedResource
    private let category: ArticleCategory
    private let articleManifest: ArticleManifestType
    private let articleAemImportService: ArticleAemImportService
    private let analytics: GodToolsAnaltyics
    
    private weak var flowDelegate: FlowDelegate?
    
    let navTitle: ObservableValue<String> = ObservableValue(value: "")
    let articleAemImportData: ObservableValue<[RealmArticleAemImportData]> = ObservableValue(value: [])
    let isLoading: ObservableValue<Bool> = ObservableValue(value: false)
    
    required init(flowDelegate: FlowDelegate, resource: DownloadedResource, category: ArticleCategory, articleManifest: ArticleManifestType, articleAemImportService: ArticleAemImportService, analytics: GodToolsAnaltyics) {
        
        self.flowDelegate = flowDelegate
        self.resource = resource
        self.category = category
        self.articleManifest = articleManifest
        self.articleAemImportService = articleAemImportService
        self.analytics = analytics
        
        navTitle.accept(value: category.title)
        
        isLoading.accept(value: true)
        articleAemImportService.download(aemImportSrcs: articleManifest.aemImportSrcs) { [weak self] in
            self?.reloadArticleAemImportData(category: category)
            self?.isLoading.accept(value: false)
        }
    }
    
    deinit {
        articleAemImportService.cancelDownload()
    }
    
    private func reloadArticleAemImportData(category: ArticleCategory) {
                
        var cachedArticleImportDataArray: [RealmArticleAemImportData] = articleAemImportService.getArticlesWithTags(aemTags: category.aemTags)
        cachedArticleImportDataArray.sort {(rhs: RealmArticleAemImportData, lhs: RealmArticleAemImportData) in
            rhs.articleJcrContent?.title?.lowercased() ?? "" < lhs.articleJcrContent?.title?.lowercased() ?? ""
        }
        
        articleAemImportData.accept(value: cachedArticleImportDataArray)
    }
    
    func pageViewed() {
        analytics.recordScreenView(screenName: "Category : \(category.title)", siteSection: resource.code, siteSubSection: "articles-list")
    }
    
    func articleTapped(articleAemImportData: RealmArticleAemImportData) {
        flowDelegate?.navigate(step: .articleTappedFromArticles(articleAemImportData: articleAemImportData, resource: resource))
    }
}
