//
//  ShareArticleView.swift
//  godtools
//
//  Created by Levi Eggert on 4/28/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

@MainActor
class ShareArticleView {
    
    let controller: UIActivityViewController
    
    init(viewModel: ShareArticleViewModel) {
        
        controller = UIActivityViewController(activityItems: [viewModel.shareArticle.shareMessage as Any], applicationActivities: nil)
        
        viewModel.pageViewed()
        viewModel.articleShared()
        
        controller.completionWithItemsHandler = { (
            activityType: UIActivity.ActivityType?,
            serviceCompleted: Bool,
            returnedItems: [Any]?,
            activityError: Error?
        ) in
            
            viewModel.activityViewDismissed()
        }
    }
}
