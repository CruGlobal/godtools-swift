//
//  ArticleCategoriesViewModelType.swift
//  godtools
//
//  Created by Levi Eggert on 4/14/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

protocol ArticleCategoriesViewModelType {
    
    var godToolsResource: GodToolsResource { get }
    var resourceLatestTranslationServices: ResourceLatestTranslationServices { get }
    var categories: ObservableValue<[ArticleCategory]> { get }
    var navTitle: ObservableValue<String> { get }
    var loadingMessage: ObservableValue<String> { get }
    var isLoading: ObservableValue<Bool> { get }
    var errorMessage: ObservableValue<ArticleCategoriesErrorMessage> { get }
    
    func pageViewed()
    func downloadArticlesTapped()
    func refreshArticles()
    func articleTapped(category: ArticleCategory)
}
