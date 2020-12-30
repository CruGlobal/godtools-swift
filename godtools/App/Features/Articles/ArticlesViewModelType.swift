//
//  ArticlesViewModelType.swift
//  godtools
//
//  Created by Levi Eggert on 4/21/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

protocol ArticlesViewModelType {
    
    var localizationServices: LocalizationServices { get }
    var navTitle: ObservableValue<String> { get }
    var articleAemImportData: ObservableValue<[ArticleAemImportData]> { get }
    var isLoading: ObservableValue<Bool> { get }
    var errorMessage: ObservableValue<ArticlesErrorMessage> { get }
    
    func pageViewed()
    func articleTapped(articleAemImportData: ArticleAemImportData)
    func downloadArticlesTapped()
}
