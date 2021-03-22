//
//  ArticleAemImportDataType.swift
//  godtools
//
//  Created by Levi Eggert on 4/23/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

protocol ArticleAemImportDataType {
        
    associatedtype ArticleJcrContentAssociatedType = ArticleJcrContentType
    
    var articleJcrContent: ArticleJcrContentAssociatedType? { get }
    var webUrl: String { get }
    var webArchiveFilename: String { get }
}
