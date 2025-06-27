//
//  ShareToolScreenShareSessionView.swift
//  godtools
//
//  Created by Levi Eggert on 11/10/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import UIKit

class ShareToolScreenShareSessionView {
    
    private let viewModel: ShareToolScreenShareSessionViewModel
        
    let controller: UIActivityViewController
    
    init(viewModel: ShareToolScreenShareSessionViewModel) {
        
        self.viewModel = viewModel
        
        let shareQRCodeActivityItem = ToolScreenShareQRCodeActivity { sharedItems in
            viewModel.qrCodeTapped()
        }
        
        controller = UIActivityViewController(
            activityItems: [viewModel.shareMessage],
            applicationActivities: [shareQRCodeActivityItem]
        )
        
        controller.completionWithItemsHandler = { _, _, _, _ in
            viewModel.activityViewDismissed()
        }
        
        viewModel.pageViewed()
    }
}
