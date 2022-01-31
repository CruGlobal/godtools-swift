//
//  MobileContentCardCollectionPageCardView.swift
//  godtools
//
//  Created by Levi Eggert on 1/26/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import UIKit

class MobileContentCardCollectionPageCardView: MobileContentView {
    
    private let viewModel: MobileContentCardCollectionPageCardViewModelType
    
    private var contentStackView: MobileContentStackView?
    
    required init(viewModel: MobileContentCardCollectionPageCardViewModelType) {
        
        self.viewModel = viewModel
        
        super.init(frame: UIScreen.main.bounds)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func renderChild(childView: MobileContentView) {
        super.renderChild(childView: childView)
                
        if let contentStackView = childView as? MobileContentStackView {
            addContentStackView(contentStackView: contentStackView)
        }
    }
}

extension MobileContentCardCollectionPageCardView {
    
    func addContentStackView(contentStackView: MobileContentStackView) {
        
        guard self.contentStackView == nil else {
            return
        }
        
        addSubview(contentStackView)
        
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        contentStackView.constrainEdgesToView(view: self)
                
        self.contentStackView = contentStackView
    }
}
