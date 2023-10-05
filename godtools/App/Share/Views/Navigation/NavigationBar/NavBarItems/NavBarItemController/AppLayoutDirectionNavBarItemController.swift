//
//  AppLayoutDirectionNavBarItemController.swift
//  godtools
//
//  Created by Levi Eggert on 10/4/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import UIKit
import Combine

class AppLayoutDirectionNavBarItemController: NarBarItemController {
    
    private let layoutDirectionBasedBarItem: AppLayoutDirectionBasedBarItem
    private let toggleVisibility: AnyPublisher<Bool, Never>
    
    private var cancellables: Set<AnyCancellable> = Set()
    
    init(viewController: UIViewController, navBarItem: AppLayoutDirectionBasedBarItem, itemBarPosition: BarButtonItemBarPosition, itemIndex: Int) {
        
        self.layoutDirectionBasedBarItem = navBarItem
        self.toggleVisibility = navBarItem.toggleVisibilityPublisher ?? CurrentValueSubject<Bool, Never>(false).eraseToAnyPublisher()
        
        super.init(
            viewController: viewController,
            navBarItem: navBarItem,
            itemBarPosition: itemBarPosition,
            itemIndex: itemIndex,
            shouldSinkToggleVisibility: false
        )
        
        Publishers.CombineLatest(
            toggleVisibility,
            ApplicationLayout.shared.semanticContentAttributePublisher
        )
        .receive(on: DispatchQueue.main)
        .sink{ [weak self] (hidden: Bool, semanticContentAttribute: UISemanticContentAttribute) in
            
            if hidden {
                self?.setHidden(hidden: hidden)
            }
            else {
                self?.updateBarItemLayoutDirection(direction: ApplicationLayout.shared.currentDirection)
            }
        }
        .store(in: &cancellables)
    }
    
    private func updateBarItemLayoutDirection(direction: ApplicationLayoutDirection) {
        
        let image: UIImage?
        
        switch direction {
        case .leftToRight:
            image = layoutDirectionBasedBarItem.leftToRightImage
        case .rightToLeft:
            image = layoutDirectionBasedBarItem.rightToLeftImage
        }
        
        let newBarButtonItem: UIBarButtonItem = navBarItem.itemData.getNewBarButtonItem(contentType: .image(value: image))
        
        super.setBarButtonItem(barButtonItem: newBarButtonItem)
    }
}
