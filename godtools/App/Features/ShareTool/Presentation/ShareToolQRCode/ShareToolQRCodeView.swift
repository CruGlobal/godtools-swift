//
//  ShareToolQRCodeView.swift
//  godtools
//
//  Created by Levi Eggert on 3/21/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import SwiftUI

struct ShareToolQRCodeView: View {
    
    @ObservedObject private var viewModel: ShareToolQRCodeViewModel
        
    init(viewModel: ShareToolQRCodeViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        
        QRCodeModalView(
            shareUrl: viewModel.shareUrl,
            qrCodeDescription: viewModel.strings.message,
            closeButtonTitle: viewModel.strings.closeActionTitle,
            closeTapped: {
                viewModel.closeTapped()
            }
        )
    }
}
