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
    private let viewConfirmRemoveToolFromFavoritesDomainModel: ViewConfirmRemoveToolFromFavoritesDomainModel
    private let removeFavoritedToolUseCase: RemoveFavoritedToolUseCase
    private let didConfirmToolRemovalSubject: PassthroughSubject<Void, Never>?
    
    let title: String?
    let message: String?
    let cancelTitle: String?
    let acceptTitle: String
    
    init(toolId: String, viewConfirmRemoveToolFromFavoritesDomainModel: ViewConfirmRemoveToolFromFavoritesDomainModel, removeFavoritedToolUseCase: RemoveFavoritedToolUseCase, didConfirmToolRemovalSubject: PassthroughSubject<Void, Never>?) {
        
        self.toolId = toolId
        self.viewConfirmRemoveToolFromFavoritesDomainModel = viewConfirmRemoveToolFromFavoritesDomainModel
        self.removeFavoritedToolUseCase = removeFavoritedToolUseCase
        self.didConfirmToolRemovalSubject = didConfirmToolRemovalSubject
        
        title = viewConfirmRemoveToolFromFavoritesDomainModel.interfaceStrings.title
        message = viewConfirmRemoveToolFromFavoritesDomainModel.interfaceStrings.message
        acceptTitle = viewConfirmRemoveToolFromFavoritesDomainModel.interfaceStrings.confirmRemoveActionTitle
        cancelTitle = viewConfirmRemoveToolFromFavoritesDomainModel.interfaceStrings.cancelRemoveActionTitle
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
    }
    
    func acceptTapped() {
        
        didConfirmToolRemovalSubject?.send(Void())
        
        ConfirmRemoveToolFromFavoritesAlertViewModel.removeToolFromFavoritesCancellable = removeFavoritedToolUseCase
            .removeToolPublisher(toolId: toolId)
            .receive(on: DispatchQueue.main)
            .sink { _ in
                
            }
    }
}
