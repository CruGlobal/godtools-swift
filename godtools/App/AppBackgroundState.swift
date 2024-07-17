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
                        
        appDiContainer.feature.appLanguage.domainLayer
            .getCurrentAppLanguageUseCase()
            .getLanguagePublisher()
            .receive(on: DispatchQueue.main)
            .assign(to: &$appLanguage)
        
        appDiContainer.feature.appLanguage.domainLayer
            .getStoreInitialAppLanguageUseCase()
            .storeInitialAppLanguagePublisher()
            .receive(on: DispatchQueue.main)
            .sink { (appLanguage: BCP47LanguageIdentifier) in

            }
            .store(in: &cancellables)
        
        syncLatestToolsForFavoritedTools(
            downloadLatestToolsForFavoritedToolsUseCase: appDiContainer.feature.dashboard.domainLayer.getDownloadLatestToolsForFavoritedToolsUseCase()
        )
                
        syncInitialFavoritedTools(
            resourcesRepository: appDiContainer.dataLayer.getResourcesRepository(),
            launchCountRepository: appDiContainer.dataLayer.getSharedLaunchCountRepository(),
            storeInitialFavoritedToolsUseCase: appDiContainer.feature.dashboard.domainLayer.getStoreInitialFavoritedToolsUseCase()
        )
    }
    
    private func syncLatestToolsForFavoritedTools(downloadLatestToolsForFavoritedToolsUseCase: DownloadLatestToolsForFavoritedToolsUseCase) {
        
        $appLanguage
            .dropFirst()
            .map { (appLanguage: AppLanguageDomainModel) in
                return downloadLatestToolsForFavoritedToolsUseCase
                    .downloadPublisher(appLanguage: appLanguage)
                    .eraseToAnyPublisher()
            }
            .switchToLatest()
            .receive(on: DispatchQueue.main)
            .sink { _ in
                
            }
            .store(in: &cancellables)
    }
    
    private func syncInitialFavoritedTools(resourcesRepository: ResourcesRepository, launchCountRepository: LaunchCountRepository, storeInitialFavoritedToolsUseCase: StoreInitialFavoritedToolsUseCase) {
        
        Publishers.CombineLatest(
            resourcesRepository.getResourcesChangedPublisher().prepend(Void()),
            launchCountRepository.getLaunchCountPublisher()
        )
        .flatMap { (resourcesChanged: Void, launchCount: Int) -> AnyPublisher<Void, Never> in
            
            guard launchCount == 1 else {
                return Just(Void())
                    .eraseToAnyPublisher()
            }
            
            return storeInitialFavoritedToolsUseCase
                .storeToolsPublisher()
                .eraseToAnyPublisher()
        }
        .receive(on: DispatchQueue.main)
        .sink { _ in
            
        }
        .store(in: &cancellables)
    }
}
