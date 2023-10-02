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
    
    private var backBarButtonItem: UIBarButtonItem?
    private var cancellables: Set<AnyCancellable> = Set()
    
    init(rootView: Content, appLayoutBasedBackButton: AppLayoutDirectionBasedBackBarButtonItem?) {
        
        self.appLayoutBasedBackButton = appLayoutBasedBackButton
        
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
    }
    
    private func updateBackButtonForLayoutDirection(direction: ApplicationLayoutDirection) {
        
        guard let appLayoutBasedBackButton = self.appLayoutBasedBackButton else {
            return
        }
        
        if let backBarButtonItem = self.backBarButtonItem {
            removeBarButtonItem(item: backBarButtonItem)
        }
        
        let newBackBarButtonItem: UIBarButtonItem = appLayoutBasedBackButton.getNewBarButtonItemForLayoutDirection(direction: ApplicationLayout.shared.currentDirection)
        
        addBarButtonItem(item: newBackBarButtonItem, barPosition: .left, index: 0)
        
        self.backBarButtonItem = newBackBarButtonItem
    }
}
