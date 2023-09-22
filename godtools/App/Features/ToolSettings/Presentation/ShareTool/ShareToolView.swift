//
//  ShareToolView.swift
//  godtools
//
//  Created by Levi Eggert on 5/13/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class ShareToolView: NSObject {
    
    private let viewModel: ShareToolViewModel
    
    init(viewModel: ShareToolViewModel, onViewReady: ((_ controller: UIActivityViewController) -> Void)?) {
        
        self.viewModel = viewModel
        
        super.init()
        
        viewModel.pageViewed()
        
        viewModel.shareMessage.addObserver(self) { (shareMessage: String) in
            
            let controller = UIActivityViewController(
                activityItems: [shareMessage],
                applicationActivities: nil
            )
            
            onViewReady?(controller)
        }
    }
}
