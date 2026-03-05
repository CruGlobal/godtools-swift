//
//  AppBackgroundState.swift
//  godtools
//
//  Created by Levi Eggert on 8/18/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import Combine
import RequestOperation

@MainActor class AppBackgroundState {
    
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
            .execute()
            .receive(on: DispatchQueue.main)
            .assign(to: &$appLanguage)
        
        appDiContainer.feature.appLanguage.domainLayer
            .getStoreInitialAppLanguageUseCase()
            .execute()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in
                
            }, receiveValue: { (appLanguage: BCP47LanguageIdentifier) in
                
            })
            .store(in: &cancellables)
        
        syncLatestToolsForFavoritedTools(
            downloadLatestToolsForFavoritedToolsUseCase: appDiContainer.domainLayer.getDownloadLatestToolsForFavoritedToolsUseCase()
        )
                
        syncInitialFavoritedTools(
            resourcesRepository: appDiContainer.dataLayer.getResourcesRepository(),
            launchCountRepository: appDiContainer.dataLayer.getLaunchCountRepository(),
            storeInitialFavoritedToolsUseCase: appDiContainer.domainLayer.getStoreInitialFavoritedToolsUseCase()
        )
        
        syncUserCounters(
            userIsAuthenticatedUseCase: appDiContainer.feature.account.domainLayer.getUserIsAuthenticatedUseCase(),
            userCountersRepository: appDiContainer.dataLayer.getUserCountersRepository()
        )
    }
    
    private func syncLatestToolsForFavoritedTools(downloadLatestToolsForFavoritedToolsUseCase: DownloadLatestToolsForFavoritedToolsUseCase) {
        
        $appLanguage
            .dropFirst()
            .map { (appLanguage: AppLanguageDomainModel) in
                return downloadLatestToolsForFavoritedToolsUseCase
                    .execute(appLanguage: appLanguage)
                    .eraseToAnyPublisher()
            }
            .switchToLatest()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in
                
            }, receiveValue: { _ in
                
            })
            .store(in: &cancellables)
    }
    
    private func syncInitialFavoritedTools(resourcesRepository: ResourcesRepository, launchCountRepository: LaunchCountRepositoryInterface, storeInitialFavoritedToolsUseCase: StoreInitialFavoritedToolsUseCase) {
        
        Publishers.CombineLatest(
            resourcesRepository.persistence.observeCollectionChangesPublisher().prepend(Void()),
            launchCountRepository.getLaunchCountPublisher()
                .setFailureType(to: Error.self)
        )
        .flatMap { (resourcesChanged: Void, launchCount: Int) -> AnyPublisher<Void, Error> in
            
            guard launchCount == 1 else {
                return Just(Void())
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            }
            
            return storeInitialFavoritedToolsUseCase
                .execute()
                .eraseToAnyPublisher()
        }
        .receive(on: DispatchQueue.main)
        .sink(receiveCompletion: { _ in
            
        }, receiveValue: { _ in
            
        })
        .store(in: &cancellables)
    }
    
    private func syncUserCounters(userIsAuthenticatedUseCase: GetUserIsAuthenticatedUseCase, userCountersRepository: UserCountersRepository) {
                       
        userIsAuthenticatedUseCase
            .execute()
            .map { (isAuthenticatedDomainModel: UserIsAuthenticatedDomainModel) in
                            
                if isAuthenticatedDomainModel.isAuthenticated {
                    
                    return userCountersRepository
                        .getCountersPublisher(
                            requestPriority: .high
                        )
                        .map { _ in
                            return Void()
                        }
                        .eraseToAnyPublisher()
                }
                else {
                    
                    return Just(Void())
                        .setFailureType(to: Error.self)
                        .eraseToAnyPublisher()
                }
            }
            .switchToLatest()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                            
                switch completion {
                case .finished:
                    break
                case .failure( _):
                    break
                }
                
            }, receiveValue: { _ in
                
            })
            .store(in: &cancellables)
    }
}
