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
        
        let qrCodeActivityItem = ToolScreenShareQRCodeActivity { sharedItems in
            print("tapped")
        }
        
        controller = UIActivityViewController(
            activityItems: [viewModel.shareMessage],
            applicationActivities: [qrCodeActivityItem]
        )
        
        viewModel.pageViewed()
    }
}
