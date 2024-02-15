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
    
    private let tool: ToolDomainModel
    private let localizationServices: LocalizationServices
    private let removeToolFromFavoritesUseCase: RemoveToolFromFavoritesUseCase
    private let didConfirmToolRemovalSubject: PassthroughSubject<Void, Never>?
    
    let title: String?
    let message: String?
    let cancelTitle: String?
    let acceptTitle: String
    
    init(tool: ToolDomainModel, localizationServices: LocalizationServices, removeToolFromFavoritesUseCase: RemoveToolFromFavoritesUseCase, didConfirmToolRemovalSubject: PassthroughSubject<Void, Never>?) {
        
        self.tool = tool
        self.localizationServices = localizationServices
        self.removeToolFromFavoritesUseCase = removeToolFromFavoritesUseCase
        self.didConfirmToolRemovalSubject = didConfirmToolRemovalSubject
        
        title = localizationServices.stringForSystemElseEnglish(key: "remove_from_favorites_title")
        message = localizationServices.stringForSystemElseEnglish(key: "remove_from_favorites_message").replacingOccurrences(of: "%@", with: tool.name)
        acceptTitle = localizationServices.stringForSystemElseEnglish(key: "yes")
        cancelTitle = localizationServices.stringForSystemElseEnglish(key: "no")
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
    }
    
    func acceptTapped() {
        
        didConfirmToolRemovalSubject?.send(Void())
        
        ConfirmRemoveToolFromFavoritesAlertViewModel.removeToolFromFavoritesCancellable = removeToolFromFavoritesUseCase.removeToolFromFavoritesPublisher(id: tool.dataModelId)
            .sink { _ in
                
            }
    }
}
