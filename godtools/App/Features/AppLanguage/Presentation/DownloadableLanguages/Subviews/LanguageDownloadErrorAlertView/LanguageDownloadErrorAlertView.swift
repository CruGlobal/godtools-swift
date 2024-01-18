//
//  LanguageDownloadErrorAlertView.swift
//  godtools
//
//  Created by Rachael Skeath on 1/6/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import UIKit

class LanguageDownloadErrorAlertView: AlertMessageView {
    
    init(viewModel: LanguageDownloadErrorAlertViewModel) {
        
        super.init(viewModel: viewModel)
    }
    
    required init(viewModel: AlertMessageViewModelType) {
        fatalError("init(viewModel:) has not been implemented")
    }
}
