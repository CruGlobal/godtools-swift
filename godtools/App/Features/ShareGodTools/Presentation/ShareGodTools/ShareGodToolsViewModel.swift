//
//  ShareGodToolsViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 4/19/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation

@MainActor
final class ShareGodToolsViewModel: ObservableObject {
    
    private let stepEmitter: FlowStepEmitter
    private let strings: ShareGodToolsStringsDomainModel
    
    @Published var shareMessage: String = ""
    
    init(stepEmitter: FlowStepEmitter, appLanguage: AppLanguageDomainModel, getShareGodToolsStringsUseCase: GetShareGodToolsStringsUseCase) {
        
        self.stepEmitter = stepEmitter
        self.strings = getShareGodToolsStringsUseCase
            .execute(appLanguage: appLanguage)
        
        shareMessage = strings.shareMessage
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
    }
}

extension ShareGodToolsViewModel {
    
    func activityViewDismissed() {
        
        stepEmitter.emit(step: AppFlowStep.dismissedShareGodToolsActivityViewController)
    }
}
