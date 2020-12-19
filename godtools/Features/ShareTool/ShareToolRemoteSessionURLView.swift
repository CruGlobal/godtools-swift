//
//  ShareToolRemoteSessionURLView.swift
//  godtools
//
//  Created by Levi Eggert on 8/14/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class ShareToolRemoteSessionURLView {
    
    private let viewModel: ShareToolRemoteSessionURLViewModelType
        
    let controller: UIActivityViewController
    
    required init(viewModel: ShareToolRemoteSessionURLViewModelType) {
        
        self.viewModel = viewModel
        
        controller = UIActivityViewController(
            activityItems: [viewModel.shareMessage],
            applicationActivities: nil
        )
        
        viewModel.pageViewed()
    }
}
