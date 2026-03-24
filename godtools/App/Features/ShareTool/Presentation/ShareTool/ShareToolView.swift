//
//  ShareToolView.swift
//  godtools
//
//  Created by Levi Eggert on 5/13/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class ShareToolView {
    
    private static let qrCodeActivityType = UIActivity.ActivityType(rawValue: "org.cru.godtools.shareToolQRCodeActivity")
    
    private let viewModel: ShareToolViewModel
    
    let controller: UIActivityViewController
    
    init(viewModel: ShareToolViewModel) {
        
        self.viewModel = viewModel
        
        let shareQRCodeActivityItem = QRCodeActivity(
            title: viewModel.strings.qrCodeActionTitle,
            activityType: Self.qrCodeActivityType
        )
        
        let applicationActivities: [UIActivity]? = [shareQRCodeActivityItem]
        
        controller = UIActivityViewController(
            activityItems: [viewModel.strings.shareMessage],
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
