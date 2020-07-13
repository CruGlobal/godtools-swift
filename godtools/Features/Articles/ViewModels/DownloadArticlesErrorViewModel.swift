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
    
    required init(error: ArticleAemImportDownloaderError) {
            
        let notConnectedToNetworkMessage: String = NSLocalizedString("no_internet", comment: "")
        let cancelledError: String = "The request was cancelled"
        let unknownError: String = NSLocalizedString("download_error", comment: "")
                
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
