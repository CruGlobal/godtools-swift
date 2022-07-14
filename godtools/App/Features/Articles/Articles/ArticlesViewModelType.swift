//
//  ArticlesViewModelType.swift
//  godtools
//
//  Created by Levi Eggert on 4/21/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

protocol ArticlesViewModelType {
    
    var navTitle: ObservableValue<String> { get }
    var numberOfArticles: ObservableValue<Int> { get }
    var isLoading: ObservableValue<Bool> { get }
    var errorMessage: ObservableValue<ArticlesErrorMessageViewModel?> { get }
    
    func pageViewed()
    func articleTapped(index: Int)
    func articleWillAppear(index: Int) -> ArticleCellViewModelType?
    func downloadArticlesTapped()
}
