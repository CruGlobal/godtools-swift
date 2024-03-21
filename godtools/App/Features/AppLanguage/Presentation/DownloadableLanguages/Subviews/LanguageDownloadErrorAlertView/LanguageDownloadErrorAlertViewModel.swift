//
//  LanguageDownloadErrorAlertViewModel.swift
//  godtools
//
//  Created by Rachael Skeath on 1/6/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation

class LanguageDownloadErrorAlertViewModel: AlertMessageViewModelType {
    
    let title: String? = "Download Error"
    let message: String?
    let cancelTitle: String? = "Ok"
    let acceptTitle: String = "Ok"
    
    init(error: Error) {
        
        message = "Try again later. Error: " + error.localizedDescription
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
    }
    
    func acceptTapped() {
        
    }
}
