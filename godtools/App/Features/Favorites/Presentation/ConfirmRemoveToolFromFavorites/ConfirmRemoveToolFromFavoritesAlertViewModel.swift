//
//  ConfirmRemoveToolFromFavoritesAlertViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 8/18/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class ConfirmRemoveToolFromFavoritesAlertViewModel: AlertMessageViewModelType {
    
    private static var removeToolFromFavoritesCancellable: AnyCancellable?
    
    private let toolId: String
    private let strings: ConfirmRemoveToolFromFavoritesStringsDomainModel
    private let removeFavoritedToolUseCase: RemoveFavoritedToolUseCase
    private let didConfirmToolRemovalSubject: PassthroughSubject<Void, Never>?
    
    let title: String?
    let message: String?
    let cancelTitle: String?
    let acceptTitle: String
    
    init(toolId: String, strings: ConfirmRemoveToolFromFavoritesStringsDomainModel, removeFavoritedToolUseCase: RemoveFavoritedToolUseCase, didConfirmToolRemovalSubject: PassthroughSubject<Void, Never>?) {
        
        self.toolId = toolId
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
        
        ConfirmRemoveToolFromFavoritesAlertViewModel.removeToolFromFavoritesCancellable = removeFavoritedToolUseCase
            .execute(
                toolId: toolId
            )
            .receive(on: DispatchQueue.main)
            .sink { _ in
                
            }
    }
}
