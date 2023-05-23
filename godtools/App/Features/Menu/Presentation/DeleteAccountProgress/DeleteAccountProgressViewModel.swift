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
    
    @Published var title: String = "Deleting account..."
    @Published var deleteStatus: String = ""
    
    init(flowDelegate: FlowDelegate, deleteAccountUseCase: DeleteAccountUseCase, localizationServices: LocalizationServices) {
        
        self.flowDelegate = flowDelegate
        self.deleteAccountUseCase = deleteAccountUseCase
        self.localizationServices = localizationServices
     
        deleteAccountUseCase.deleteAccountPublisher()
            .receiveOnMain()
            .sink { [weak self] subscribersCompletion in
                
                switch subscribersCompletion {
                    
                case .finished:
                    self?.flowDelegate?.navigate(step: .didFinishAccountDeletionWithSuccessFromDeleteAccountProgress)
                    
                case .failure(let error):
                    self?.flowDelegate?.navigate(step: .didFinishAccountDeletionWithErrorFromDeleteAccountProgress(error: error))
                }
                
            } receiveValue: { _ in
                
            }
            .store(in: &cancellables)
    }
}
