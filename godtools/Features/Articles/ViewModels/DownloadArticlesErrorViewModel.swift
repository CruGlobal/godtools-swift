//
//  DownloadArticlesErrorViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 5/24/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class DownloadArticlesErrorViewModel {
    
    let message: String
    
    required init(localizationServices: LocalizationServices, error: ArticleAemImportDownloaderError) {
            
        let notConnectedToNetworkMessage: String = localizationServices.stringForMainBundle(key: "no_internet")
        let cancelledError: String = "The request was cancelled"
        let unknownError: String = localizationServices.stringForMainBundle(key: "download_error")
                
        switch error {
        
        case .cancelled:
            message = cancelledError
            
        case .noNetworkConnection:
            message = notConnectedToNetworkMessage
            
        case .unknownError:
            message = unknownError
        }
    }
}
