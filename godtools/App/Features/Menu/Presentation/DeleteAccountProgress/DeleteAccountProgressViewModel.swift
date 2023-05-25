//
//  DeleteAccountProgressViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 5/23/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class DeleteAccountProgressViewModel: ObservableObject {
    
    private let deleteAccountUseCase: DeleteAccountUseCase
    private let localizationServices: LocalizationServices
    
    private var cancellables: Set<AnyCancellable> = Set()
    
    private weak var flowDelegate: FlowDelegate?
    
    @Published var title: String
    
    init(flowDelegate: FlowDelegate, deleteAccountUseCase: DeleteAccountUseCase, localizationServices: LocalizationServices) {
        
        self.flowDelegate = flowDelegate
        self.deleteAccountUseCase = deleteAccountUseCase
        self.localizationServices = localizationServices
        
        title = localizationServices.stringForMainBundle(key: "deleteAccountProgress.title")
                     
        deleteAccountUseCase.deleteAccountPublisher()
            .receiveOnMain()
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
            .store(in: &cancellables)
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
