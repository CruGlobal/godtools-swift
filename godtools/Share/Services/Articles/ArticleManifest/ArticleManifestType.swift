//
//  ArticleManifestType.swift
//  godtools
//
//  Created by Levi Eggert on 4/24/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

protocol ArticleManifestType {
    
    var title: String? { get }
    var attributes: ArticleManifestAttributes? { get }
    var categories: [ArticleCategory] { get }
    var aemImportSrcs: [String] { get }
    
    func getResource(filename: String) -> ArticleResource?
}
