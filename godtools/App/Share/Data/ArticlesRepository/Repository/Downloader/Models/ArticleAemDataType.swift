//
//  ArticleAemDataType.swift
//  godtools
//
//  Created by Levi Eggert on 4/23/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

protocol ArticleAemDataType {
        
    associatedtype ArticleJcrContentAssociatedType = ArticleJcrContentType
    
    var aemUri: String { get }
    var articleJcrContent: ArticleJcrContentAssociatedType? { get }
    var webUrl: String { get }
    var updatedAt: Date { get }
}
