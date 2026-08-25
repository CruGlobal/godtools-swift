//
//  DeleteAccountProgressViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 5/23/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine
import Flow

@MainActor
final class DeleteAccountProgressViewModel: ObservableObject {
        
    private let stepEmitter: FlowStepEmitter
    private let getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase
    private let getDeleteAccountProgressStringsUseCase: GetDeleteAccountProgressStringsUseCase
    private let deleteAccountUseCase: DeleteAccountUseCase
    private let minimumSecondsToDisplayDeleteAccountProgress: TimeInterval = 2
    
    private var cancellables: Set<AnyCancellable> = Set()
        
    @Published private var appLanguage: AppLanguageDomainModel = ""
    
    @Published private(set) var strings = DeleteAccountProgressStringsDomainModel.emptyValue
    
    init(
        stepEmitter: FlowStepEmitter,
        getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase,
        getDeleteAccountProgressStringsUseCase: GetDeleteAccountProgressStringsUseCase,
        deleteAccountUseCase: DeleteAccountUseCase
    ) {
        
        self.stepEmitter = stepEmitter
        self.getCurrentAppLanguageUseCase = getCurrentAppLanguageUseCase
        self.getDeleteAccountProgressStringsUseCase = getDeleteAccountProgressStringsUseCase
        self.deleteAccountUseCase = deleteAccountUseCase
        
        getCurrentAppLanguageUseCase
            .execute()
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] (appLanguage: AppLanguageDomainModel) in
                
                self?.appLanguage = appLanguage
                self?.didSetAppLanguage(appLanguage: appLanguage)
            })
            .store(in: &cancellables)
        
        deleteAccount()
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
    }
    
    private func didSetAppLanguage(appLanguage: AppLanguageDomainModel) {

        strings = getDeleteAccountProgressStringsUseCase
            .execute(appLanguage: appLanguage)
    }
    
    private func deleteAccount() {
        
        let startDeleteAccountTime = Date()
        
        Task {
            
            let error: Error?
            
            do {
                try await deleteAccountUseCase
                    .execute()
                error = nil
            }
            catch let deleteAccountError {
                error = deleteAccountError
            }
            
            let seconds = getRemainingSecondsToDisplayDeleteAccountProgress(startTime: startDeleteAccountTime)
            
            try? await Task.sleep(for: .seconds(seconds))
            
            didFinishAccountDeletion(error: error)
        }
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
            stepEmitter.emit(step: AppFlowStep.didFinishAccountDeletionWithErrorFromDeleteAccountProgress(error: deleteAccountError))
        }
        else {
            stepEmitter.emit(step: AppFlowStep.didFinishAccountDeletionWithSuccessFromDeleteAccountProgress)
        }
    }
}
