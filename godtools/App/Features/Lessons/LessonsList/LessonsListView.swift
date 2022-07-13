//
//  LessonsListView.swift
//  godtools
//
//  Created by Levi Eggert on 4/5/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit
import SwiftUI

class LessonsListView: UIHostingController<LessonsListContentView>, ToolsMenuPageView {
    
    private let contentView: LessonsListContentView
    
    required init(contentView: LessonsListContentView) {
        
        self.contentView = contentView
        
        super.init(rootView: contentView)
    }
    
    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func pageViewed() {
        
        // TODO
    }
    
    func scrollToTop(animated: Bool) {
        // TODO: Implementing this method because this View implements ToolsMenuPageView protocol.  This method will need to go away when GT-1545 is implemented. (https://jira.cru.org/browse/GT-1545)  ~Levi
    }
}
