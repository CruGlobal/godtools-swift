//
//  ShareToolQRCodeViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 3/21/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation

@MainActor class ShareToolQRCodeViewModel: ObservableObject {
    
    private let shareToolQRCodeUseCase: ShareToolQRCodeUseCase
    
    private weak var flowDelegate: FlowDelegate?
    
    @Published private(set) var shareToolQrCode: ShareToolQRCodeDomainModel?
    
    init(flowDelegate: FlowDelegate, shareToolQRCodeUseCase: ShareToolQRCodeUseCase) {
        
        self.flowDelegate = flowDelegate
        self.shareToolQRCodeUseCase = shareToolQRCodeUseCase
    }
}

// MARK: - Inputs

extension ShareToolQRCodeViewModel {
    
    func closeTapped() {
        
    }
}
