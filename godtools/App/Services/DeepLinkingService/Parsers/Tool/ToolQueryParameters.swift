//
//  ToolQueryParameters.swift
//  godtools
//
//  Created by Levi Eggert on 6/26/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

struct ToolQueryParameters: Codable {
    
    let abbreviation: String?
    let icid: String?
    let liveShareStream: String?
    let parallelLanguageCodesString: String?
    let primaryLanguageCodesString: String?
    let page: String?
    
    enum CodingKeys: String, CodingKey {
        case abbreviation = "abbreviation"
        case icid = "icid"
        case liveShareStream = "liveShareStream"
        case parallelLanguageCodesString = "parallelLanguage"
        case primaryLanguageCodesString = "primaryLanguage"
        case page = "page"
    }
}

extension ToolQueryParameters {
    
    func getPrimaryLanguageCodes() -> [String] {
        guard let primaryLanguageCodesString = self.primaryLanguageCodesString else {
            return Array()
        }
        return primaryLanguageCodesString.components(separatedBy: ",")
    }
    
    func getParallelLanguageCodes() -> [String] {
        guard let parallelLanguageCodesString = self.parallelLanguageCodesString else {
            return Array()
        }
        return parallelLanguageCodesString.components(separatedBy: ",")
    }
}
