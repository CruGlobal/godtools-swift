//
//  QRCodeView.swift
//  godtools
//
//  Created by Rachael Skeath on 7/7/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import SwiftUI
import CoreImage.CIFilterBuiltins

struct QRCodeView<Content: View>: View {
    
    private let data: Data
    private let fallbackView: Content
    
    init(data: Data, @ViewBuilder fallbackView: () -> Content = { Image(systemName: "xmark.circle").resizable().scaledToFit() }) {
        
        self.data = data
        self.fallbackView = fallbackView()
    }
    
    var body: some View {
        
        if let qrCode = generateQRCode() {
            
            Image(uiImage: qrCode)
                .interpolation(.none)
                .resizable()
                .scaledToFit()
            
        } else {
            fallbackView
        }
    }
    
    private func generateQRCode() -> UIImage? {
        let context = CIContext()
        let filter = CIFilter.qrCodeGenerator()
        
        filter.message = data
        
        guard let outputImage = filter.outputImage else { return nil }
        guard let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else { return nil }
        
        return UIImage(cgImage: cgImage)
    }
}
