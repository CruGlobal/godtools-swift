//
//  ArticleViewModelType.swift
//  godtools
//
//  Created by Levi Eggert on 4/14/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

protocol ArticleViewModelType {
    
    var navTitle: ObservableValue<String> { get }
    
    func pageViewed()
}
