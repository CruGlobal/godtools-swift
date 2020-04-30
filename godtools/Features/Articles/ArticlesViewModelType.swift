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
    var articleAemImportData: ObservableValue<[RealmArticleAemImportData]> { get }
    var isLoading: ObservableValue<Bool> { get }
    
    func pageViewed()
    func articleTapped(articleAemImportData: RealmArticleAemImportData)
}
