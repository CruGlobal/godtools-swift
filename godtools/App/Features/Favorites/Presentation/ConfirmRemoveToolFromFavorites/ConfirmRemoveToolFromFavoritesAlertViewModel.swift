//
//  ConfirmRemoveToolFromFavoritesAlertViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 8/18/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

@MainActor
final class ConfirmRemoveToolFromFavoritesAlertViewModel {
    
    private static var removeToolFromFavoritesTask: Task<Void, Error>?
    
    private let toolId: String
    private let appLanguage: AppLanguageDomainModel
    private let strings: ConfirmRemoveToolFromFavoritesStringsDomainModel
    private let removeFavoritedToolUseCase: RemoveFavoritedToolUseCase
    private let didConfirmToolRemovalSubject: PassthroughSubject<Void, Never>?
    
    let title: String
    let message: String
    let cancelTitle: String?
    let acceptTitle: String
    
    init(
        toolId: String,
        appLanguage: AppLanguageDomainModel,
        strings: ConfirmRemoveToolFromFavoritesStringsDomainModel,
        removeFavoritedToolUseCase: RemoveFavoritedToolUseCase,
        didConfirmToolRemovalSubject: PassthroughSubject<Void, Never>?
    ) {

        self.toolId = toolId
        self.appLanguage = appLanguage
        self.strings = strings
        self.removeFavoritedToolUseCase = removeFavoritedToolUseCase
        self.didConfirmToolRemovalSubject = didConfirmToolRemovalSubject
        
        title = strings.title
        message = strings.message
        acceptTitle = strings.confirmRemoveActionTitle
        cancelTitle = strings.cancelRemoveActionTitle
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
    }
    
    func cancelTapped() {
        
    }
    
    func acceptTapped() {
        
        didConfirmToolRemovalSubject?.send(Void())
        
        Self.removeToolFromFavoritesTask?.cancel()
        
        Self.removeToolFromFavoritesTask = Task {
            
            _ = try await removeFavoritedToolUseCase
                .execute(toolId: toolId)
        }
    }
}
