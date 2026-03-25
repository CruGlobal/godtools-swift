//
//  ToolScreenShareQRCodeView.swift
//  godtools
//
//  Created by Rachael Skeath on 6/26/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import SwiftUI

struct ToolScreenShareQRCodeView: View {
        
    @ObservedObject private var viewModel: ToolScreenShareQRCodeViewModel
    
    init(viewModel: ToolScreenShareQRCodeViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        
        QRCodeModalView(
            shareUrl: viewModel.shareUrl,
            qrCodeDescription: viewModel.strings.qrCodeDescription,
            closeButtonTitle: viewModel.strings.closeButtonTitle,
            closeTapped: {
                viewModel.closeTapped()
            }
        )
    }
}
