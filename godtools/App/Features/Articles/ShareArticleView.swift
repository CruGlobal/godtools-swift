//
//  ShareArticleView.swift
//  godtools
//
//  Created by Levi Eggert on 4/28/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class ShareArticleView {
    
    let controller: UIActivityViewController
    
    required init(viewModel: ShareArticleViewModelType) {
        
        controller = UIActivityViewController(activityItems: [viewModel.shareMessage as Any], applicationActivities: nil)
        
        viewModel.pageViewed()
        viewModel.articleShared()
    }
}
