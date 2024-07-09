//
//  AppLanguageCodable.swift
//  godtools
//
//  Created by Levi Eggert on 5/7/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation

struct AppLanguageCodable: Codable {
    
    private static let languageDirectionLeftToRight: String = "ltr"
    private static let languageDirectionRightToLeft: String = "rtl"
    
    let languageCode: String
    let languageDirectionValue: String
    let languageScriptCode: String?
    
    enum RootKeys: String, CodingKey {
        case languageCode = "language_code"
        case languageDirection = "language_direction"
        case languageScriptCode = "language_script_code"
    }
    
    init(languageCode: String, languageDirection: AppLanguageDataModel.Direction, languageScriptCode: String?) {
        
        self.languageCode = languageCode
        self.languageDirectionValue = languageDirection == .rightToLeft ? AppLanguageCodable.languageDirectionRightToLeft : AppLanguageCodable.languageDirectionLeftToRight
        self.languageScriptCode = languageScriptCode
    }
    
    init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: RootKeys.self)
        
        languageCode = try container.decode(String.self, forKey: .languageCode)
        languageDirectionValue = try container.decode(String.self, forKey: .languageDirection)
        languageScriptCode = try container.decodeIfPresent(String.self, forKey: .languageScriptCode)
    }
}

extension AppLanguageCodable: AppLanguageDataModelInterface {
    
    var languageDirection: AppLanguageDataModel.Direction {
        return languageDirectionValue == AppLanguageCodable.languageDirectionRightToLeft ? .rightToLeft : .leftToRight
    }
}
