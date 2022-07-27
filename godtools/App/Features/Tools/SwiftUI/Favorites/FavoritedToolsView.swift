//
//  FavoritedToolsView.swift
//  godtools
//
//  Created by Levi Eggert on 5/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit
import SwiftUI

class FavoritedToolsView: UIHostingController<FavoritesContentView>, ToolsMenuPageView {
    
    private let contentView: FavoritesContentView
    
    required init(contentView: FavoritesContentView) {
        
        self.contentView = contentView
        
        super.init(rootView: contentView)
    }
    
    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func pageViewed() {
        contentView.viewModel.pageViewed()
    }
}
