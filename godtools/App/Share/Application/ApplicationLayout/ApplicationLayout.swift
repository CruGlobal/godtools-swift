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

@MainActor
class ApplicationLayout: ObservableObject {
        
    static let shared: ApplicationLayout = ApplicationLayout()
    
    private let semanticContentAttributeSubject: CurrentValueSubject<UISemanticContentAttribute, Never>
    
    private var cancellables: Set<AnyCancellable> = Set()
    private var isConfigured: Bool = false
    
    private(set) var currentDirection: ApplicationLayoutDirection = .leftToRight
    
    @Published private var appLanguage: AppLanguageDomainModel = LanguageCodeDomainModel.english.value
    
    @Published private(set) var layoutDirection: LayoutDirection
    
    var semanticContentAttributePublisher: AnyPublisher<UISemanticContentAttribute, Never> {
        return semanticContentAttributeSubject
            .eraseToAnyPublisher()
    }
    
    private init() {
        
        layoutDirection = currentDirection.layoutDirection
        semanticContentAttributeSubject = CurrentValueSubject(currentDirection.semanticContentAttribute)
    }
        
    func configure(appLanguageDiContainer: AppLanguageDiContainer) {
        
        guard !isConfigured else {
            return
        }
        
        isConfigured = true
        
        let getCurrentAppLanguageUseCase = appLanguageDiContainer.domainLayer.getCurrentAppLanguageUseCase()
        
        getCurrentAppLanguageUseCase
            .execute()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (appLanguage: AppLanguageDomainModel) in
                
                self?.appLanguage = appLanguage
                self?.didSetAppLanguage(appLanguage: appLanguage, appLanguageDiContainer: appLanguageDiContainer)
            }
            .store(in: &cancellables)
    }
    
    private func didSetAppLanguage(appLanguage: AppLanguageDomainModel, appLanguageDiContainer: AppLanguageDiContainer) {
        
        refreshLayoutDirection(appLanguage: appLanguage, appLanguageDiContainer: appLanguageDiContainer)
    }
    
    private func refreshLayoutDirection(appLanguage: AppLanguageDomainModel, appLanguageDiContainer: AppLanguageDiContainer) {
        
        let getInterfaceLayoutDirectionUseCase = appLanguageDiContainer.domainLayer.getInterfaceLayoutDirectionUseCase()
        
        let interfaceLayoutDirection: AppInterfaceLayoutDirectionDomainModel = getInterfaceLayoutDirectionUseCase.execute(appLanguage: appLanguage)
        
        let newLayoutDirection: ApplicationLayoutDirection = interfaceLayoutDirection == .leftToRight ? .leftToRight : .rightToLeft
        
        if newLayoutDirection != currentDirection {
            
            currentDirection = newLayoutDirection
            
            layoutDirection = newLayoutDirection.layoutDirection
            semanticContentAttributeSubject.send(newLayoutDirection.semanticContentAttribute)
        }
    }
}
