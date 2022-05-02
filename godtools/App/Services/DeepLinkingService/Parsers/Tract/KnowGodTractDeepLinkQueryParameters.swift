//
//  KnowGodTractDeepLinkQueryParameters.swift
//  godtools
//
//  Created by Levi Eggert on 4/14/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

struct KnowGodTractDeepLinkQueryParameters: Codable {
    
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

extension KnowGodTractDeepLinkQueryParameters {
    
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
