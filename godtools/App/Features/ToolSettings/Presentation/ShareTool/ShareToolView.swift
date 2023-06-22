//
//  ShareToolView.swift
//  godtools
//
//  Created by Levi Eggert on 5/13/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class ShareToolView {
    
    private let viewModel: ShareToolViewModel
    
    let controller: UIActivityViewController
    
    init(viewModel: ShareToolViewModel) {
        
        self.viewModel = viewModel
        
        controller = UIActivityViewController(
            activityItems: [viewModel.shareMessage],
            applicationActivities: nil
        )
        
        viewModel.pageViewed()
    }
}
