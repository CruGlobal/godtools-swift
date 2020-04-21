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
    private let articleManifestXmlParser: ArticleManifestXmlParser
    private let analytics: GodToolsAnaltyics
    
    private weak var flowDelegate: FlowDelegate?
    
    required init(flowDelegate: FlowDelegate, resource: DownloadedResource, category: ArticleCategory, articleManifestXmlParser: ArticleManifestXmlParser, analytics: GodToolsAnaltyics) {
        
        self.flowDelegate = flowDelegate
        self.resource = resource
        self.category = category
        self.articleManifestXmlParser = articleManifestXmlParser
        self.analytics = analytics
    }
    
    func pageViewed() {
        analytics.recordScreenView(screenName: "Category : \(category.title)", siteSection: resource.code, siteSubSection: "articles-list")
    }
}
