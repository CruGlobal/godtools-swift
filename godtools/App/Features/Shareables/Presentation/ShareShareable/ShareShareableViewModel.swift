//
//  ShareShareableViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 5/23/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import UIKit
import Combine

@MainActor
final class ShareShareableViewModel {
            
    private let stepEmitter: FlowStepEmitter
    private let incrementUserCounterUseCase: IncrementUserCounterUseCase
   
    let imageToShare: UIImage
    
    private var cancellables = Set<AnyCancellable>()
    
    init(
        stepEmitter: FlowStepEmitter,
        imageToShare: UIImage,
        incrementUserCounterUseCase: IncrementUserCounterUseCase
    ) {
        
        self.stepEmitter = stepEmitter
        self.imageToShare = imageToShare
        self.incrementUserCounterUseCase = incrementUserCounterUseCase
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
    }
}

// MARK: - Inputs

extension ShareShareableViewModel {
    
    func pageViewed() {
        
        let incrementUserCounterUseCase: IncrementUserCounterUseCase = self.incrementUserCounterUseCase
        
        Task.detached {
            
            _ = try await incrementUserCounterUseCase.execute(interaction: .imageShared)
        }
    }
    
    func activityViewDismissed() {
        
        stepEmitter.emit(step: AppFlowStep.dismissedShareShareableActivityViewController)
    }
}
