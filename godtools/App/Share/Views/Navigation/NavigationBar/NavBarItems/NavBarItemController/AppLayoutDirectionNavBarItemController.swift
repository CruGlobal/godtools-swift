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
    
    private var layoutDirectionPublisher: AnyPublisher<UISemanticContentAttribute, Never>
    private var currentSemanticContentAttribute: UISemanticContentAttribute?
    private var cancellables: Set<AnyCancellable> = Set()
    
    init(viewController: UIViewController, navBarItem: AppLayoutDirectionBasedBarItem, itemBarPosition: BarButtonItemBarPosition, itemIndex: Int, layoutDirectionPublisher: AnyPublisher<UISemanticContentAttribute, Never>? = nil) {
        
        self.layoutDirectionBasedBarItem = navBarItem
        self.layoutDirectionPublisher = layoutDirectionPublisher ?? ApplicationLayout.shared.semanticContentAttributePublisher
        
        super.init(
            viewController: viewController,
            navBarItem: navBarItem,
            itemBarPosition: itemBarPosition,
            itemIndex: itemIndex
        )
        
        self.layoutDirectionPublisher
        .receive(on: DispatchQueue.main)
        .sink{ [weak self] (semanticContentAttribute: UISemanticContentAttribute) in
            
            let shouldRedraw: Bool = self?.currentSemanticContentAttribute != semanticContentAttribute
            
            if shouldRedraw, let newBarButtonItem = self?.getNewBarItemBasedOnLayoutDirection(semanticContentAttribute: semanticContentAttribute) {
                
                self?.reDrawBarButtonItem(barButtonItem: newBarButtonItem)
            }

            self?.currentSemanticContentAttribute = semanticContentAttribute
        }
        .store(in: &cancellables)
    }
    
    private func getNewBarItemBasedOnLayoutDirection(semanticContentAttribute: UISemanticContentAttribute) -> UIBarButtonItem {
        
        let image: UIImage?
        
        if semanticContentAttribute == .forceRightToLeft {
            image = layoutDirectionBasedBarItem.rightToLeftImage
        }
        else {
            image = layoutDirectionBasedBarItem.leftToRightImage
        }
        
        let newBarButtonItem: UIBarButtonItem = navBarItem.itemData.getNewBarButtonItem(contentType: .image(value: image))
        
        return newBarButtonItem
    }
}
