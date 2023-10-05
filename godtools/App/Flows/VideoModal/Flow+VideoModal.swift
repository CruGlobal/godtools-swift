//
//  Flow+VideoModal.swift
//  godtools
//
//  Created by Levi Eggert on 1/31/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import UIKit
import SwiftUI

extension Flow {
    
    func presentVideoModal(viewModel: FullScreenVideoViewModel, screenAccessibility: AccessibilityStrings.Screen, closeVideoButtonAccessibility: AccessibilityStrings.Button) {
                
        let videoBackgroundColor: Color = .black
        
        let view = FullScreenVideoView(
            viewModel: viewModel,
            backgroundColor: videoBackgroundColor,
            screenAccessibility: screenAccessibility
        )
        
        let closeButton = AppCloseBarItem(
            color: nil,
            target: viewModel,
            action: #selector(viewModel.closeTapped),
            accessibilityIdentifier: closeVideoButtonAccessibility.id
        )
        
        let hostingView = AppHostingController<FullScreenVideoView>(
            rootView: view,
            navigationBar: AppNavigationBar(
                backButton: nil,
                leadingItems: [],
                trailingItems: [closeButton]
            )
        )
        
        hostingView.view.backgroundColor = UIColor(videoBackgroundColor)
        
        let modal = ModalNavigationController(rootView: hostingView, navBarColor: .black, navBarIsTranslucent: true, controlColor: .white, statusBarStyle: .default)
               
        modal.view.backgroundColor = UIColor(videoBackgroundColor)
        
        navigationController.present(modal, animated: true)
    }
    
    func dismissVideoModal(animated: Bool, completion: (() -> Void)?) {
        
        navigationController.dismissPresented(animated: animated, completion: completion)
    }
}
