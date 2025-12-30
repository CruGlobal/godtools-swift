//
//  SwiftCategoryArticle.swift
//  godtools
//
//  Created by Levi Eggert on 9/22/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import SwiftData
import RepositorySync

@available(iOS 17.4, *)
typealias SwiftCategoryArticle = SwiftCategoryArticleV1.SwiftCategoryArticle

@available(iOS 17.4, *)
enum SwiftCategoryArticleV1 {
 
    @Model
    class SwiftCategoryArticle: IdentifiableSwiftDataObject {
        
        var aemTag: String = ""
        var aemUris: [String] = Array<String>()
        var categoryId: String = ""
        var languageCode: String = ""
        
        @Attribute(.unique) var id: String = ""
        @Attribute(.unique) var uuid: String = ""
        
        init() {
            
        }
    }
}
