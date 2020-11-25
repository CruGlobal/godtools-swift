//
//  ToolPageContentFormViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 11/9/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

protocol ToolPageModalViewModelDelegate: class {
    
    func presentModal(modalViewModel: ToolPageModalViewModel)
    func dismissModal(modalViewModel: ToolPageModalViewModel)
}

class ToolPageModalViewModel: NSObject, ToolPageModalViewModelType {
    
    private let modalNode: ModalNode
    private let diContainer: ToolPageDiContainer
    private let toolPageColors: ToolPageColorsViewModel
    private let defaultTextNodeTextColor: UIColor?
    
    private weak var delegate: ToolPageModalViewModelDelegate?
    
    let contentViewModel: ToolPageContentStackContainerViewModel
    
    required init(delegate: ToolPageModalViewModelDelegate, modalNode: ModalNode, diContainer: ToolPageDiContainer, toolPageColors: ToolPageColorsViewModel, defaultTextNodeTextColor: UIColor?) {
        
        self.delegate = delegate
        self.modalNode = modalNode
        self.diContainer = diContainer
        self.toolPageColors = toolPageColors
        self.defaultTextNodeTextColor = defaultTextNodeTextColor
        
        contentViewModel = ToolPageContentStackContainerViewModel(
            node: modalNode,
            diContainer: diContainer,
            toolPageColors: toolPageColors,
            defaultTextNodeTextColor: nil,
            defaultTextNodeTextAlignment: .center,
            defaultButtonBorderColor: UIColor.white
        )
        
        super.init()
        
        addObservers()
    }
    
    deinit {
        
        removeObservers()
    }
    
    private func addObservers() {
        
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
        }
    }
    
    private func removeObservers() {
        diContainer.mobileContentEvents.eventButtonTappedSignal.removeObserver(self)
    }
    
    var backgroundColor: UIColor {
        return UIColor.black.withAlphaComponent(0.9)
    }
}
