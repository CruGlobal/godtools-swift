//
//  Flow+VideoModal.swift
//  godtools
//
//  Created by Levi Eggert on 1/31/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import UIKit
import SwiftUI

extension GTFlow {
    
    func presentVideoModal(viewModel: FullScreenVideoViewModel, screenAccessibility: AccessibilityStrings.Screen) {
                
        let videoBackgroundColor: Color = .black
        
        let view = FullScreenVideoView(
            viewModel: viewModel,
            backgroundColor: videoBackgroundColor,
            screenAccessibility: screenAccessibility
        )
        
        let closeButton = AppCloseBarItem(
            color: nil,
            target: viewModel,
            action: #selector(viewModel.closeTapped)
        )
        
        let hostingView = AppHostingController<FullScreenVideoView>(
            rootView: view,
            navigationBar: AppNavigationBar(
                appearance: nil,
                backButton: nil,
                leadingItems: [],
                trailingItems: [closeButton]
            )
        )
        
        hostingView.view.backgroundColor = UIColor(videoBackgroundColor)
        
        let modal = ModalNavigationController(rootView: hostingView, navBarColor: .black, navBarIsTranslucent: true, controlColor: .white, statusBarStyle: .default)
               
        modal.view.backgroundColor = UIColor(videoBackgroundColor)
        
        presentView(view: modal, animated: true)
    }
    
    func dismissVideoModal(animated: Bool, completion: (() -> Void)?) {
        
        dismissView(animated: animated, completion: completion)
    }
}
