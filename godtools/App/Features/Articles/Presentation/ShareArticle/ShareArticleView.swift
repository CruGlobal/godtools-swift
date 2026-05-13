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
        
        controller = UIActivityViewController(activityItems: [viewModel.shareMessage as Any], applicationActivities: nil)
        
        viewModel.pageViewed()
        viewModel.articleShared()
    }
}
