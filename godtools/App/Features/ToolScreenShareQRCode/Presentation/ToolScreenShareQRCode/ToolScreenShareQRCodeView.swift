//
//  ToolScreenShareQRCodeView.swift
//  godtools
//
//  Created by Rachael Skeath on 6/26/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import SwiftUI
import CoreImage.CIFilterBuiltins

struct ToolScreenShareQRCodeView: View {
        
    @ObservedObject private var viewModel: ToolScreenShareQRCodeViewModel
    
    init(viewModel: ToolScreenShareQRCodeViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {

        GTModalView {
            
            VStack {
                HStack {
                    Spacer()
                    
                    CloseButton {
                        viewModel.closeTapped()
                    }
                    .padding(.top, 20)
                    .padding(.trailing, 25)
                }
                
                Image(uiImage: generateQRCode())
                    .interpolation(.none)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .padding(.top, 53)
                    .padding(.bottom, 20)
                
                Text(viewModel.interfaceStrings?.qrCodeDescription ?? "")
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 25)
                    .padding(.horizontal, 70)
                                
                GTBlueButton(title: viewModel.interfaceStrings?.closeButtonTitle ?? "", font: FontLibrary.sfProDisplayRegular.font(size: 16), width: 150, height: 48) {
                    viewModel.closeTapped()
                }
                .padding(.bottom, 125)
            }
            
        } overlayTappedClosure: {
            
            viewModel.closeTapped()
        }
        .environment(\.layoutDirection, ApplicationLayout.shared.layoutDirection)
    }
    
    func generateQRCode() -> UIImage {
        let context = CIContext()
        let filter = CIFilter.qrCodeGenerator()
        
        filter.message = Data(viewModel.shareUrl.utf8)
        
        if let outputImage = filter.outputImage {
            if let cgImage = context.createCGImage(outputImage, from: outputImage.extent) {
                return UIImage(cgImage: cgImage)
            }
        }
        
        return UIImage(systemName: "xmark.circle") ?? UIImage()
    }
}
