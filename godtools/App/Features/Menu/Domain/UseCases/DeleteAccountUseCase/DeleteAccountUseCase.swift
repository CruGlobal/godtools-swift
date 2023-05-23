//
//  DeleteAccountUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 5/23/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class DeleteAccountUseCase {
    
    init() {
        
    }
    
    func deleteAccountPublisher() -> AnyPublisher<Void, Error> {
        
        return deleteAccountWithDelay()
            .eraseToAnyPublisher()
    }
    
    private func deleteAccountWithDelay() -> AnyPublisher<Void, Error> {
        
        return Future() { promise in
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                
                promise(.success(()))
            }
        }
        .eraseToAnyPublisher()
    }
}
