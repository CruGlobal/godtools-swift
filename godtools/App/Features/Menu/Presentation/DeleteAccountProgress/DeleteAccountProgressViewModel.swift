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
    private let statusMessage: CurrentValueSubject<String, Never> = CurrentValueSubject("")
    
    private var cancellables: Set<AnyCancellable> = Set()
    
    private weak var flowDelegate: FlowDelegate?
    
    @Published var title: String
    @Published var deleteStatus: String = ""
    
    init(flowDelegate: FlowDelegate, deleteAccountUseCase: DeleteAccountUseCase, localizationServices: LocalizationServices) {
        
        self.flowDelegate = flowDelegate
        self.deleteAccountUseCase = deleteAccountUseCase
        self.localizationServices = localizationServices
        
        title = localizationServices.stringForMainBundle(key: "deleteAccountProgress.title")
     
        statusMessage
            .receiveOnMain()
            .sink { [weak self] (message: String) in
                self?.deleteStatus = message
            }
            .store(in: &cancellables)
        
        deleteAccountUseCase.deleteAccountPublisher(statusMessage: statusMessage)
            .receiveOnMain()
            .sink { [weak self] subscribersCompletion in
                
                let deleteAccountError: Error?
                
                switch subscribersCompletion {
                    
                case .finished:
                    deleteAccountError = nil
                    
                case .failure(let error):
                    deleteAccountError = error
                }
                
                DispatchQueue.main.async {
                    
                    if let deleteAccountError = deleteAccountError {
                        self?.flowDelegate?.navigate(step: .didFinishAccountDeletionWithErrorFromDeleteAccountProgress(error: deleteAccountError))
                    }
                    else {
                        self?.flowDelegate?.navigate(step: .didFinishAccountDeletionWithSuccessFromDeleteAccountProgress)
                    }
                }
                
            } receiveValue: { _ in
                
            }
            .store(in: &cancellables)
    }
}
