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
        
        VStack {
            
            Spacer()
            Spacer()
            
            Image(uiImage: generateQRCode())
                .interpolation(.none)
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 200)
            
            Spacer()
            
            Text(viewModel.interfaceStrings?.qrCodeDescription ?? "")
            
            Spacer()
            
            GTBlueButton(title: viewModel.interfaceStrings?.closeButtonTitle ?? "", width: 150, height: 48) {
                
            }
            
            Spacer()
            Spacer()
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
