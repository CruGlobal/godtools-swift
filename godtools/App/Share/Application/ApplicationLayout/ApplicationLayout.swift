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
    
    private let semanticContentAttributeSubject: CurrentValueSubject<UISemanticContentAttribute, Never>
    
    private var cancellables: Set<AnyCancellable> = Set()
    private var isConfigured: Bool = false
    
    private(set) var currentDirection: ApplicationLayoutDirection = .leftToRight
    
    @Published var layoutDirection: LayoutDirection
    
    var semanticContentAttributePublisher: AnyPublisher<UISemanticContentAttribute, Never> {
        return semanticContentAttributeSubject
            .eraseToAnyPublisher()
    }
    
    private init() {
        
        layoutDirection = currentDirection.layoutDirection
        semanticContentAttributeSubject = CurrentValueSubject(currentDirection.semanticContentAttribute)
    }
        
    func configure(appLanguageFeatureDiContainer: AppLanguageFeatureDiContainer) {
        
        guard !isConfigured else {
            return
        }
        
        isConfigured = true
        
        appLanguageFeatureDiContainer.domainLayer.getInterfaceLayoutDirectionUseCase().observeLayoutDirectionPublisher()
            .receive(on: DispatchQueue.main)
            .sink { (interfaceLayoutDirection: AppInterfaceLayoutDirectionDomainModel) in
                
                let newLayoutDirection: ApplicationLayoutDirection = interfaceLayoutDirection == .leftToRight ? .leftToRight : .rightToLeft
                
                if newLayoutDirection != self.currentDirection {
                    
                    self.currentDirection = newLayoutDirection
                    
                    self.layoutDirection = newLayoutDirection.layoutDirection
                    self.semanticContentAttributeSubject.send(newLayoutDirection.semanticContentAttribute)
                }
            }
            .store(in: &cancellables)
    }
}
