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
    
    func scrollToTop(animated: Bool) {
        // TODO: Implementing this method because this View implements ToolsMenuPageView protocol.  This method will need to go away when GT-1545 is implemented. (https://jira.cru.org/browse/GT-1545)  ~Levi
    }
}
