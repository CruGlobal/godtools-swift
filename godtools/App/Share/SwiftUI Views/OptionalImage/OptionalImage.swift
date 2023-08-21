//
//  OptionalImage.swift
//  godtools
//
//  Created by Rachael Skeath on 4/20/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

struct OptionalImage: View {
    
    private let imageData: OptionalImageData?
    private let imageSize: OptionalImageSize
    private let contentMode: ContentMode
    private let placeholderColor: Color
    
    init(imageData: OptionalImageData?, imageSize: OptionalImageSize, contentMode: ContentMode, placeholderColor: Color) {
        
        self.imageData = imageData
        self.imageSize = imageSize
        self.contentMode = contentMode
        self.placeholderColor = placeholderColor
    }
    
    var body: some View {
      
        ZStack(alignment: .topLeading) {
            
            Rectangle()
                .fill(placeholderColor)
                .frame(width: imageSize.width, height: imageSize.height)
            
            if let image = imageData?.image {
                
                image
                    .resizable()
                    .aspectRatio(contentMode: contentMode)
                    .frame(width: imageSize.width, height: imageSize.height)
                    .clipped()
                    .id(imageData?.imageIdForAnimationChange)
                    .transition(.opacity.animation(.easeOut))
                
            }
        }
        .frame(width: imageSize.width, height: imageSize.height)
    }
}

struct OptionalImage_Previews: PreviewProvider {
    
    static var previews: some View {
        
        OptionalImage(
            imageData: nil,
            imageSize: .fixed(width: 300, height: 150),
            contentMode: .fill,
            placeholderColor: .blue
        )
    }
}
