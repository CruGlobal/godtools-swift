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
    
    required init(error: ArticlesServiceError) {
        
        let notConnectedToNetworkMessage: String = NSLocalizedString("no_internet", comment: "")
        let cancelledError: String = "The request was cancelled"
        let unknownError: String = NSLocalizedString("download_error", comment: "")
                
        switch error {
            
        case .aemImportServiceError(let error):
            
            switch error {
                
            case .apiError(let error):
                switch error {
                case .cancelled:
                    message = cancelledError
                case .noNetworkConnection:
                    message = notConnectedToNetworkMessage
                }
            case .failedToCacheAemImportDataToRealm( _):
                message = unknownError
            case .failedToCacheWebArchivePlistData( _):
                message = unknownError
            case .webArchiveOperationsFailed( _):
                message = unknownError
            case .webArchiveError(let error):
                switch error {
                case .cancelled:
                    message = cancelledError
                case .noNetworkConnection:
                    message = notConnectedToNetworkMessage
                }
            }
            
        case .fetchManifestError(let error):
            if error.requestCancelled {
                message = cancelledError
            }
            else if error.notConnectedToInternet {
                message = notConnectedToNetworkMessage
            }
            else {
                message = unknownError
            }
        }
    }
}
