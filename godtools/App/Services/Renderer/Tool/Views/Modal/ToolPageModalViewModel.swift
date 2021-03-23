//
//  ToolPageContentFormViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 11/9/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class ToolPageModalViewModel: ToolPageModalViewModelType {
    
    private let modalNode: ModalNode
    private let pageModel: MobileContentRendererPageModel
            
    required init(modalNode: ModalNode, pageModel: MobileContentRendererPageModel) {
        
        self.modalNode = modalNode
        self.pageModel = pageModel
        
//        contentViewModel = ToolPageContentStackContainerViewModel(
//            node: modalNode,
//            diContainer: diContainer,
//            toolPageColors: toolPageColors,
//            defaultTextNodeTextColor: nil,
//            defaultTextNodeTextAlignment: .center,
//            defaultButtonBorderColor: UIColor.white
//        )
                
        addObservers()
    }
    
    private func addObservers() {
        
        /*
        diContainer.mobileContentEvents.eventButtonTappedSignal.addObserver(self) { [weak self] (buttonEvent: ButtonEvent) in
            guard let viewModel = self else {
                return
            }
            
            if viewModel.modalNode.listeners.contains(buttonEvent.event) {
                self?.delegate?.presentModal(modalViewModel: viewModel)
            }
            else if viewModel.modalNode.dismissListeners.contains(buttonEvent.event) {
                self?.delegate?.dismissModal(modalViewModel: viewModel)
            }
        }*/
    }
    
    var backgroundColor: UIColor {
        return UIColor.black.withAlphaComponent(0.9)
    }
    
    var listeners: [String] {
        return modalNode.listeners
    }
    
    var dismissListeners: [String] {
        return modalNode.dismissListeners
    }
}
