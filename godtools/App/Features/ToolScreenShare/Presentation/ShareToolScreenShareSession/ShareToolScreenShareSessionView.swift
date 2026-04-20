//
//  ShareToolScreenShareSessionView.swift
//  godtools
//
//  Created by Levi Eggert on 11/10/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import UIKit

class ShareToolScreenShareSessionView {
    
    private static let qrCodeActivityType = UIActivity.ActivityType(rawValue: "org.cru.godtools.screenShareQRCodeActivity")
    
    private let viewModel: ShareToolScreenShareSessionViewModel
    
    let controller: UIActivityViewController
    
    init(viewModel: ShareToolScreenShareSessionViewModel) {
        
        self.viewModel = viewModel
                
        let shareQRCodeActivityItem = QRCodeActivity(
            title: viewModel.strings.qrCodeActionTitle,
            activityType: Self.qrCodeActivityType
        )
        
        let applicationActivities: [UIActivity]? = [shareQRCodeActivityItem]
        
        controller = UIActivityViewController(
            activityItems: [viewModel.shareMessage],
            applicationActivities: applicationActivities
        )
        
        controller.completionWithItemsHandler = { (activityType: UIActivity.ActivityType?, serviceCompleted: Bool, returnedItems: [Any]?, activityError: Error?) in
            
            if activityType == Self.qrCodeActivityType {
                viewModel.qrCodeTapped()
            }
            else {
                viewModel.activityViewDismissed()
            }
        }
        
        viewModel.pageViewed()
    }
}
