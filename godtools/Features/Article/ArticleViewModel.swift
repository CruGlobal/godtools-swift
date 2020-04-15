//
//  ArticleViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 4/14/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class ArticleViewModel: ArticleViewModelType {
    
    private let articleManager: ArticleManager
    private let languageManager: LanguagesManager
    private let resource: DownloadedResource
    private let analytics: GodToolsAnaltyics
    
    let navTitle: ObservableValue<String> = ObservableValue(value: "")
    
    required init(articleManager: ArticleManager, languageManager: LanguagesManager, resource: DownloadedResource, analytics: GodToolsAnaltyics) {
        
        self.articleManager = articleManager
        self.languageManager = languageManager
        self.resource = resource
        self.analytics = analytics
        
        navTitle.accept(value: resource.name)
    }
    
    func pageViewed() {
        analytics.recordScreenView(screenName: "Categories", siteSection: resource.code, siteSubSection: "")
    }
}
