//
//  LessonQueryParameters.swift
//  godtools
//
//  Created by Levi Eggert on 6/28/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

struct LessonQueryParameters: Codable {
    
    let abbreviation: String?
    let primaryLanguageCodesString: String?
    
    enum CodingKeys: String, CodingKey {
        case abbreviation = "abbreviation"
        case primaryLanguageCodesString = "primaryLanguage"
    }
}

extension LessonQueryParameters {
    
    func getPrimaryLanguageCodes() -> [String] {
        guard let primaryLanguageCodesString = self.primaryLanguageCodesString else {
            return Array()
        }
        return primaryLanguageCodesString.components(separatedBy: ",")
    }
}
