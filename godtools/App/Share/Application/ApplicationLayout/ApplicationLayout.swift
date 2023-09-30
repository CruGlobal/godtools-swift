//
//  ApplicationLayout.swift
//  godtools
//
//  Created by Levi Eggert on 9/15/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine
import UIKit
import SwiftUI

class ApplicationLayout: ObservableObject {
        
    static let shared: ApplicationLayout = ApplicationLayout()
    
    private let semanticContentAttributeSubject: CurrentValueSubject<UISemanticContentAttribute, Never> = CurrentValueSubject(.forceLeftToRight)
    
    private var cancellables: Set<AnyCancellable> = Set()
    private var isConfigured: Bool = false
    
    @Published var layoutDirection: LayoutDirection = .leftToRight
    
    var semanticContentAttributePublisher: AnyPublisher<UISemanticContentAttribute, Never> {
        return semanticContentAttributeSubject
            .eraseToAnyPublisher()
    }
    
    private init() {
        
    }
    
    func configure(appFlow: AppFlow, appLanguageFeatureDiContainer: AppLanguageFeatureDiContainer) {
        
        guard !isConfigured else {
            return
        }
        
        isConfigured = true
        
        appLanguageFeatureDiContainer.domainLayer.getInterfaceLayoutDirectionUseCase().observeLayoutDirectionPublisher()
            .receive(on: DispatchQueue.main)
            .sink { (interfaceLayoutDirection: AppInterfaceLayoutDirectionDomainModel) in
                
                let semanticContentAttribute: UISemanticContentAttribute
                
                switch interfaceLayoutDirection {
                
                case .leftToRight:
                    self.layoutDirection = .leftToRight
                    semanticContentAttribute = .forceLeftToRight
                    
                case .rightToLeft:
                    self.layoutDirection = .rightToLeft
                    semanticContentAttribute = .forceRightToLeft
                }
                
                // NOTE: Setting UIView.appearance() globally will effect all UIViews, UINavigationBar Items, and UINavigationController navigation direction. ~Levi
                UIView.appearance().semanticContentAttribute = semanticContentAttribute
                
                self.semanticContentAttributeSubject.send(semanticContentAttribute)
                
                // NOTE: This is necessary when globally setting UIView.appearance().semanticContentAttribute.  Must remove the view and then add it back.  Here we remove the root and add back to the UIWindow. ~Levi
                appFlow.getInitialView().view.removeFromSuperview()
                AppDelegate.getWindow()?.addSubview(appFlow.getInitialView().view)
                
                // NOTE: Here we had to re-allocate the dashboard in order for the dashboard tab bar items to flip and for the pages to flip.  This is due to a bug in iOS 16.3.1. where a TabView
                // won't behave correctly for right to left languages and the current fix is to wrap TabView and force it in a left to right layout and manually build the pages and tab items for right to left layouts. ~Levi
                appFlow.reallocateDashboard()
            }
            .store(in: &cancellables)
    }
}
