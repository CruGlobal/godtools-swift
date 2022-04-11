//
//  ArticleCategoriesViewModelType.swift
//  godtools
//
//  Created by Levi Eggert on 4/14/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

protocol ArticleCategoriesViewModelType {
    
    var numberOfCategories: ObservableValue<Int> { get }
    var isLoading: ObservableValue<Bool> { get }
    
    func pageViewed()
    func categoryWillAppear(index: Int) -> ArticleCategoryCellViewModelType
    func categoryTapped(index: Int)
    func refreshArticles()
    func backButtonTapped()
}
