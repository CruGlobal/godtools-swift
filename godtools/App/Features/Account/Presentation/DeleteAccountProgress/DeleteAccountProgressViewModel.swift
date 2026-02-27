//
//  DeleteAccountProgressViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 5/23/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

@MainActor class DeleteAccountProgressViewModel: ObservableObject {
    
    private static var backgroundCancellables: Set<AnyCancellable> = Set()
    
    private let deleteAccountUseCase: DeleteAccountUseCase
    private let minimumSecondsToDisplayDeleteAccountProgress: TimeInterval = 2
    
    private var cancellables: Set<AnyCancellable> = Set()
    
    private weak var flowDelegate: FlowDelegate?
    
    @Published private var appLanguage: AppLanguageDomainModel = ""
    
    @Published private(set) var strings = DeleteAccountProgressStringsDomainModel.emptyValue
    
    init(flowDelegate: FlowDelegate, getCurrentAppLanguage: GetCurrentAppLanguageUseCase, getDeleteAccountProgressStringsUseCase: GetDeleteAccountProgressStringsUseCase, deleteAccountUseCase: DeleteAccountUseCase) {
        
        self.flowDelegate = flowDelegate
        self.deleteAccountUseCase = deleteAccountUseCase
        
        getCurrentAppLanguage
            .execute()
            .receive(on: DispatchQueue.main)
            .assign(to: &$appLanguage)
        
        $appLanguage
            .dropFirst()
            .map { (appLanguage: AppLanguageDomainModel) in
                getDeleteAccountProgressStringsUseCase
                    .execute(appLanguage: appLanguage)
            }
            .switchToLatest()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (strings: DeleteAccountProgressStringsDomainModel) in
                self?.strings = strings
            }
            .store(in: &cancellables)
        
        deleteAccount()
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
    }
    
    private func deleteAccount() {
        
        let startDeleteAccountTime = Date()
        
        deleteAccountUseCase
            .execute()
            .receive(on: DispatchQueue.main)
            .delay(for: .seconds(getRemainingSecondsToDisplayDeleteAccountProgress(startTime: startDeleteAccountTime)), scheduler: DispatchQueue.main)
            .sink { [weak self] subscribersCompletion in
                
                let deleteAccountError: Error?
                
                switch subscribersCompletion {
                    
                case .finished:
                    deleteAccountError = nil
                    
                case .failure(let error):
                    deleteAccountError = error
                }
                
                self?.didFinishAccountDeletion(error: deleteAccountError)
                
            } receiveValue: { _ in
                
            }
            .store(in: &Self.backgroundCancellables)
    }
    
    private func getRemainingSecondsToDisplayDeleteAccountProgress(startTime: Date) -> TimeInterval {
        
        let elapsedTimeInSeconds: TimeInterval = Date().timeIntervalSince(startTime)
        
        var remainingSeconds: TimeInterval = minimumSecondsToDisplayDeleteAccountProgress - elapsedTimeInSeconds
        
        if remainingSeconds < 0 {
            remainingSeconds = 0
        }
        
        return remainingSeconds
    }
    
    private func didFinishAccountDeletion(error: Error?) {
                
        if let deleteAccountError = error {
            flowDelegate?.navigate(step: .didFinishAccountDeletionWithErrorFromDeleteAccountProgress(error: deleteAccountError))
        }
        else {
            flowDelegate?.navigate(step: .didFinishAccountDeletionWithSuccessFromDeleteAccountProgress)
        }
    }
}
