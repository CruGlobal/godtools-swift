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
                
        let shareQRCodeActivityItem = ToolScreenShareQRCodeActivity(
            title: viewModel.qrCodeString
        )
        
        let applicationActivities: [UIActivity]? = [shareQRCodeActivityItem]
        
        controller = UIActivityViewController(
            activityItems: [viewModel.shareMessage],
            applicationActivities: applicationActivities
        )
        
        controller.completionWithItemsHandler = { (activityType: UIActivity.ActivityType?, serviceCompleted: Bool, returnedItems: [Any]?, activityError: Error?) in
            
            if activityType == ToolScreenShareQRCodeActivity.activityType {
                viewModel.qrCodeTapped()
            }
            else {
                viewModel.activityViewDismissed()
            }
        }
        
        viewModel.pageViewed()
    }
}
