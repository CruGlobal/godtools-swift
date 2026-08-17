//
//  WebContentType.swift
//  godtools
//
//  Created by Levi Eggert on 4/8/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

protocol WebContentType: Sendable {
    
    var appLanguage: AppLanguageDomainModel { get }
    var navTitle: String { get }
    var navTitleLocalizedKey: String { get }
    var url: URL? { get }
    var analyticsScreenName: String { get }
    var analyticsSiteSection: String { get }
    var localizationServices: LocalizationServicesInterface { get }
}

extension WebContentType {
   
    func getLocalizedNavTitle() -> String {
        
        let strings: [String: String] = localizationServices.stringsForKeys(
            keys: [
                navTitleLocalizedKey
            ],
            fetchOrder: localizationServices.getDefaultFetchOrder(localeIdentifier: appLanguage),
            shouldFallbackToKey: localizationServices.defaultFallbackToKey
        )

        return strings[navTitleLocalizedKey] ?? ""
    }
}
