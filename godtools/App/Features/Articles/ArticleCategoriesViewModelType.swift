//
//  ArticleCategoriesViewModelType.swift
//  godtools
//
//  Created by Levi Eggert on 4/14/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

protocol ArticleCategoriesViewModelType: DownloadManifestArticlesViewModelType {
    
    var navTitle: ObservableValue<String> { get }
    var numberOfCategories: ObservableValue<Int> { get }
    var loadingMessage: ObservableValue<String> { get }
    
    func pageViewed()
    func categoryWillAppear(index: Int) -> ArticleCategoryCellViewModelType
    func categoryTapped(index: Int)
    func downloadArticlesTapped()
    func refreshArticles()
}
