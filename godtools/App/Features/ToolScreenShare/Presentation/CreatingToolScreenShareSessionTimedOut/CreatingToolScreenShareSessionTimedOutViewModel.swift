//
//  CreatingToolScreenShareSessionTimedOutViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 11/8/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

@MainActor
final class CreatingToolScreenShareSessionTimedOutViewModel {
        
    private let stepEmitter: FlowStepEmitter
    private let appLanguage: AppLanguageDomainModel
    
    private var cancellables = Set<AnyCancellable>()
        
    let title: String
    let message: String
    let cancelTitle: String? = nil
    let acceptTitle: String
    
    init(
        stepEmitter: FlowStepEmitter,
        appLanguage: AppLanguageDomainModel,
        getCreatingToolScreenShareSessionTimedOutStringsUseCase: GetCreatingToolScreenShareSessionTimedOutStringsUseCase
    ) async {
        
        self.stepEmitter = stepEmitter
        self.appLanguage = appLanguage
        
        let strings = getCreatingToolScreenShareSessionTimedOutStringsUseCase
            .execute(appLanguage: appLanguage)
                
        title = strings.title
        message = strings.message
        acceptTitle = strings.acceptActionTitle
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
    }
}

// MARK: - Inputs

extension CreatingToolScreenShareSessionTimedOutViewModel {
    
    func cancelTapped() {
        stepEmitter.emit(step: AppFlowStep.cancelTappedFromCreateToolScreenShareSessionTimeout)
    }
    
    func acceptTapped() {
        stepEmitter.emit(step: AppFlowStep.acceptTappedFromCreateToolScreenShareSessionTimeout)
    }
}
