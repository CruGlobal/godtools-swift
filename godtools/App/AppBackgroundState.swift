//
//  AppBackgroundState.swift
//  godtools
//
//  Created by Levi Eggert on 8/18/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import Combine

class AppBackgroundState {
    
    static let shared: AppBackgroundState = AppBackgroundState()
        
    private var storeInitialFavoritedToolsUseCase: StoreInitialFavoritedToolsUseCase?
    private var cancellables: Set<AnyCancellable> = Set()
    private var isStarted: Bool = false
    
    @Published private var appLanguage: AppLanguageDomainModel = ""
    
    private init() {
        
    }
    
    func start(appDiContainer: AppDiContainer) {
        
        guard !isStarted else {
            return
        }
        
        isStarted = true
        
        let downloadLatestToolsForFavoritedToolsUseCase: DownloadLatestToolsForFavoritedToolsUseCase = appDiContainer.feature.dashboard.domainLayer.getDownloadLatestToolsForFavoritedToolsUseCase()
        
        appDiContainer.feature.appLanguage.domainLayer
            .getCurrentAppLanguageUseCase()
            .getLanguagePublisher()
            .assign(to: &$appLanguage)
        
        $appLanguage
            .eraseToAnyPublisher()
            .flatMap({ (appLanguage: AppLanguageDomainModel) -> AnyPublisher<Void, Never> in
                
                return downloadLatestToolsForFavoritedToolsUseCase
                    .downloadPublisher(appLanguage: appLanguage)
                    .eraseToAnyPublisher()
            })
            .sink { _ in
                
            }
            .store(in: &cancellables)
            
        self.storeInitialFavoritedToolsUseCase = appDiContainer.domainLayer.getStoreInitialFavoritedToolsUseCase()
    }
}
