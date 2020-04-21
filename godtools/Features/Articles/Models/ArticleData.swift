//
//  ArticleManifestJSON.swift
//  godtools
//
//  Created by Igor Ostriz on 30/11/2018.
//  Copyright © 2018 Cru. All rights reserved.
//


import Foundation

struct ArticleData: Codable {
    
    var canonical: String?
    var local: URL?
    var title: String?
    var url: URL?
}

extension ArticleData: Comparable {
    
    static func < (lhs: ArticleData, rhs: ArticleData) -> Bool {
        let thisTitle: String = lhs.title ?? ""
        let thatTitle: String = rhs.title ?? ""
        
        return thisTitle < thatTitle
    }
    
    static func == (lhs: ArticleData, rhs: ArticleData) -> Bool {
        return lhs.url?.path == rhs.url?.path
    }
}

extension ArticleData: Hashable {
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(url)
    }
}
