//
//  AppLayoutDirectionBasedHostingController.swift
//  godtools
//
//  Created by Levi Eggert on 10/1/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import UIKit
import SwiftUI
import Combine

class AppLayoutDirectionBasedHostingController<Content: View>: UIHostingController<Content> {
    
    private let appLayoutBasedBackButton: AppLayoutDirectionBasedBackBarButtonItem?
    private let toggleBackButtonVisibilityPublisher: AnyPublisher<Bool, Never>?
    private let backButtonBarPosition: BarButtonItemBarPosition = .left
    private let backButtonIndex: Int = 0
    
    private var backBarButtonItem: UIBarButtonItem?
    private var cancellables: Set<AnyCancellable> = Set()
    
    init(rootView: Content, appLayoutBasedBackButton: AppLayoutDirectionBasedBackBarButtonItem?, toggleBackButtonVisibilityPublisher: AnyPublisher<Bool, Never>? = nil) {
        
        self.appLayoutBasedBackButton = appLayoutBasedBackButton
        self.toggleBackButtonVisibilityPublisher = toggleBackButtonVisibilityPublisher
        
        super.init(rootView: rootView)
        
        updateBackButtonForLayoutDirection(direction: ApplicationLayout.shared.currentDirection)
    }
    
    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ApplicationLayout.shared.semanticContentAttributePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (semanticContentAttribute: UISemanticContentAttribute) in

                self?.updateBackButtonForLayoutDirection(direction: ApplicationLayout.shared.currentDirection)
            }
            .store(in: &cancellables)
        
        toggleBackButtonVisibilityPublisher?
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (backButtonHidden: Bool) in
                
                self?.setBackButtonHidden(hidden: backButtonHidden)
            }
            .store(in: &cancellables)
    }
    
    private func updateBackButtonForLayoutDirection(direction: ApplicationLayoutDirection) {
        
        guard let appLayoutBasedBackButton = self.appLayoutBasedBackButton else {
            return
        }
        
        if let backBarButtonItem = self.backBarButtonItem {
            removeBarButtonItem(item: backBarButtonItem)
        }
        
        let newBackBarButtonItem: UIBarButtonItem = appLayoutBasedBackButton.getNewBarButtonItemForLayoutDirection(direction: ApplicationLayout.shared.currentDirection)
        
        addBarButtonItem(item: newBackBarButtonItem, barPosition: backButtonBarPosition, index: backButtonIndex)
        
        self.backBarButtonItem = newBackBarButtonItem
    }
    
    private func setBackButtonHidden(hidden: Bool) {
        
        guard let backBarButtonItem = self.backBarButtonItem else {
            return
        }
        
        if hidden {
            removeBarButtonItem(item: backBarButtonItem)
        }
        else {
            addBarButtonItem(item: backBarButtonItem, barPosition: backButtonBarPosition, index: backButtonIndex)
        }
    }
}
