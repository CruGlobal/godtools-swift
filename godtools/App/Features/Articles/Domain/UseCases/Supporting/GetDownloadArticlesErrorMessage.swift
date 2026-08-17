//
//  GetDownloadArticlesErrorMessage.swift
//  godtools
//
//  Created by Levi Eggert on 7/23/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation

final class GetDownloadArticlesErrorMessage: Sendable {
    
    private let localizationServices: LocalizationServicesInterface
    
    init(localizationServices: LocalizationServicesInterface) {
        
        self.localizationServices = localizationServices
    }
    
    func getErrorMessage(appLanguage: AppLanguageDomainModel, error: Error) -> String {
        
        if error.isUrlErrorCancelledCode {
            
            return "The request was cancelled"
        }

        let noInternetKey: String = LocalizableStringKeys.noInternet.key
        let downloadErrorKey: String = LocalizableStringKeys.downloadError.key

        let strings: [String: String] = localizationServices.stringsForKeys(
            keys: [
                noInternetKey,
                downloadErrorKey
            ],
            fetchOrder: localizationServices.getDefaultFetchOrder(localeIdentifier: appLanguage),
            shouldFallbackToKey: localizationServices.defaultFallbackToKey
        )

        if error.isUrlErrorNotConnectedToInternetCode {
            
            return strings[noInternetKey] ?? ""
        }
        else {
            
            return strings[downloadErrorKey] ?? ""
        }
    }
}
