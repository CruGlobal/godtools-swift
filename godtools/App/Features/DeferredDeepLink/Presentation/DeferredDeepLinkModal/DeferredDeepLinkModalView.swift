//
//  DeferredDeepLinkModalView.swift
//  godtools
//
//  Created by Rachael Skeath on 8/27/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import SwiftUI

struct DeferredDeepLinkModalView: View {
    
    @ObservedObject private var viewModel: DeferredDeepLinkModalViewModel
    
    init(viewModel: DeferredDeepLinkModalViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack {
            
            HStack {
                CloseButton(buttonSize: 13) {
                    viewModel.closeButtonTapped()
                }
                
                Spacer()
            }
            .padding(.top, 32)
            
            Text(viewModel.modalTitle)
                .font(FontLibrary.sfProDisplayLight.font(size: 28))
                .foregroundColor(ColorPalette.gtBlue.color)
                .multilineTextAlignment(.center)
                .padding(.top, 76)
            
            Text(viewModel.modalMessage)
                .multilineTextAlignment(.center)
                .font(FontLibrary.sfProDisplayLight.font(size: 16))
                .foregroundColor(ColorPalette.gtGrey.color)
                .padding(.top, 15)
            
            Spacer()
            Spacer()
            
            HStack {
                
                PasteButton(payloadType: String.self, onPaste: { pastedItems in
                    DispatchQueue.main.async {
                        viewModel.pasteButtonTapped(pastedString: pastedItems.first)
                    }
                })
                .labelStyle(.titleAndIcon)
                .tint(ColorPalette.gtBlue.color)
                .buttonBorderShape(.roundedRectangle(radius: 6))
            }
            
            Spacer()
        }
        .padding(.horizontal, 32)
    }
}
