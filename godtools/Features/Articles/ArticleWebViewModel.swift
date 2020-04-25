//
//  ArticleWebViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 4/23/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class ArticleWebViewModel: ArticleWebViewModelType {
    
    private let articleAemImportData: RealmArticleAemImportData
    private let resource: DownloadedResource
    private let analytics: GodToolsAnaltyics
    
    let navTitle: ObservableValue<String> = ObservableValue(value: "")
    let url: ObservableValue<URL?> = ObservableValue(value: nil)
    
    required init(articleAemImportData: RealmArticleAemImportData, resource: DownloadedResource, analytics: GodToolsAnaltyics) {
        
        self.articleAemImportData = articleAemImportData
        self.resource = resource
        self.analytics = analytics
        
        navTitle.accept(value: articleAemImportData.articleJcrContent?.title ?? "")
        
        if let articleUrl = URL(string: articleAemImportData.webUrl) {
            url.accept(value: articleUrl)
        }
    }
    
    func pageViewed() {
        
        analytics.recordScreenView(
            screenName: "Article : \(articleAemImportData.articleJcrContent?.title ?? "")",
            siteSection: resource.code,
            siteSubSection: "article"
        )
    }
}
