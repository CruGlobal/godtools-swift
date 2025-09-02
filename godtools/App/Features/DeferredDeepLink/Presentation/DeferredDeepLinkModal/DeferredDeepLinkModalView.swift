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
            
            Text("It looks like you clicked a link for GodTools")
                .font(FontLibrary.sfProDisplayLight.font(size: 28))
                .foregroundColor(ColorPalette.gtBlue.color)
                .multilineTextAlignment(.center)
                .padding(.top, 76)
            
            Text("Please tap the paste button below.  This will allow us to take you to the content you requested in GodTools.")
                .multilineTextAlignment(.center)
                .font(FontLibrary.sfProDisplayLight.font(size: 16))
                .foregroundColor(ColorPalette.gtGrey.color)
                .padding(.top, 15)
            
            Spacer()
            Spacer()
            
            HStack {
                
                PasteButton(payloadType: String.self, onPaste: { pastedItems in
                    
                    viewModel.pasteButtonTapped(pastedString: pastedItems.first)
                })
                .tint(ColorPalette.gtBlue.color)
                .buttonBorderShape(.roundedRectangle(radius: 6))
                .scaleEffect(1.1)
            }
            
            Spacer()
        }
        .padding(.horizontal, 32)
    }
}
