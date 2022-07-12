//
//  ShareArticleViewModelType.swift
//  godtools
//
//  Created by Levi Eggert on 4/28/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

protocol ShareArticleViewModelType {
    
    var shareMessage: String { get }
    
    func pageViewed()
    func articleShared()
}
