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
    
    private(set) static var direction: ApplicationLayoutDirection = .leftToRight
    
    static let shared: ApplicationLayout = ApplicationLayout()
    
    private var cancellables: Set<AnyCancellable> = Set()
    private var isConfigured: Bool = false
    
    @Published var layoutDirection: LayoutDirection = .leftToRight
    
    private init() {
        
    }
    
    func configure(appLanguageFeatureDiContainer: AppLanguageFeatureDiContainer) {
        
        guard !isConfigured else {
            return
        }
        
        isConfigured = true
        
        appLanguageFeatureDiContainer.domainLayer.getAppUILayoutDirectionUseCase().observeLayoutDirectionPublisher()
            .receive(on: DispatchQueue.main)
            .sink { (appLayoutDirection: AppUILayoutDirectionDomainModel) in
                
                switch appLayoutDirection {
                
                case .leftToRight:
                    self.layoutDirection = .leftToRight
                    
                case .rightToLeft:
                    self.layoutDirection = .rightToLeft
                }
            }
            .store(in: &cancellables)
    }
    
    static func setLayoutDirection(direction: ApplicationLayoutDirection) {
        
        //ApplicationLayout.direction = direction
        
        // Globablly set all UIKit UIView's to flip direction for language.  This appears to apply to UINavigationController navigation push and pop as well. ~Levi
        //UIView.appearance().semanticContentAttribute = direction.semanticContentAttribute
    }
}
