//
//  ToolShortcutItem.swift
//  godtools
//
//  Created by Levi Eggert on 6/29/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class ToolShortcutItem: UIApplicationShortcutItem {
    
    private static let keyUserInfoTractUrl: String = "key_userinfo_tract_url"
    
    static func shortcutItem(translationsRepository: TranslationsRepository, resource: ResourceModel, primaryLanguageCode: String, parallelLanguageCode: String?) -> UIApplicationShortcutItem {
        
        let shortcutName: String

        if let translation = translationsRepository.getLatestTranslation(resourceId: resource.id, languageCode: primaryLanguageCode) {
            shortcutName = translation.translatedName
        }
        else {
            shortcutName = resource.name
        }
        
        let urlString: String
        
        let primaryUrlString: String = "godtools://knowgod.com/" + primaryLanguageCode + "/" + resource.abbreviation + "/0"
        if let parallelLanguageCode = parallelLanguageCode {
            urlString = primaryUrlString + "?parallelLanguage=" + parallelLanguageCode
        }
        else {
            urlString = primaryUrlString
        }
        
        return UIApplicationShortcutItem(
            type: ShortcutItemType.tool.rawValue,
            localizedTitle: shortcutName,
            localizedSubtitle: nil,
            icon: nil,
            userInfo: [ToolShortcutItem.keyUserInfoTractUrl: urlString as NSSecureCoding]
        )
    }
    
    static func getTractUrl(shortcutItem: UIApplicationShortcutItem) -> URL? {
        if let urlString = shortcutItem.userInfo?[ToolShortcutItem.keyUserInfoTractUrl] as? String {
            return URL(string: urlString)
        }
        return nil
    }
}
