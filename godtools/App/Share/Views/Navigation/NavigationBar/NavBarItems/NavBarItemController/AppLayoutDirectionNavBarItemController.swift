//
//  AppLayoutDirectionNavBarItemController.swift
//  godtools
//
//  Created by Levi Eggert on 10/4/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import UIKit
import Combine

class AppLayoutDirectionNavBarItemController: NavBarItemController {
    
    private let layoutDirectionBasedBarItem: AppLayoutDirectionBasedBarItem
    
    private var currentSemanticContentAttribute: UISemanticContentAttribute?
    private var cancellables: Set<AnyCancellable> = Set()
    
    init(viewController: UIViewController, navBarItem: AppLayoutDirectionBasedBarItem, itemBarPosition: BarButtonItemBarPosition, itemIndex: Int) {
        
        self.layoutDirectionBasedBarItem = navBarItem
        
        super.init(
            viewController: viewController,
            navBarItem: navBarItem,
            itemBarPosition: itemBarPosition,
            itemIndex: itemIndex
        )
        
        ApplicationLayout.shared.semanticContentAttributePublisher
        .receive(on: DispatchQueue.main)
        .sink{ [weak self] (semanticContentAttribute: UISemanticContentAttribute) in
            
            let shouldRedraw: Bool = self?.currentSemanticContentAttribute != semanticContentAttribute
            
            if shouldRedraw, let newBarButtonItem = self?.getNewBarItemBasedOnLayoutDirection() {
                
                self?.reDrawBarButtonItem(barButtonItem: newBarButtonItem)
            }

            self?.currentSemanticContentAttribute = semanticContentAttribute
        }
        .store(in: &cancellables)
    }
    
    private func getNewBarItemBasedOnLayoutDirection() -> UIBarButtonItem {
        
        let image: UIImage?
        
        switch ApplicationLayout.shared.currentDirection {
        case .leftToRight:
            image = layoutDirectionBasedBarItem.leftToRightImage
        case .rightToLeft:
            image = layoutDirectionBasedBarItem.rightToLeftImage
        }
        
        let newBarButtonItem: UIBarButtonItem = navBarItem.itemData.getNewBarButtonItem(contentType: .image(value: image))
        
        return newBarButtonItem
    }
}
