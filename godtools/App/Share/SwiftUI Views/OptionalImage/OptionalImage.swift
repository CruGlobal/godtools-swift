//
//  OptionalImage.swift
//  godtools
//
//  Created by Rachael Skeath on 4/20/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

struct OptionalImage: View {
    
    private let image: Image?
    private let imageSize: OptionalImageSize
    private let contentMode: ContentMode
    private let placeholderColor: Color
    
    init(image: Image?, imageSize: OptionalImageSize, contentMode: ContentMode, placeholderColor: Color) {
        
        self.image = image
        self.imageSize = imageSize
        self.contentMode = contentMode
        self.placeholderColor = placeholderColor
    }
    
    var body: some View {
      
        if let image = image {
            
            image
                .resizable()
                .aspectRatio(contentMode: contentMode)
                .frame(width: imageSize.width, height: imageSize.height)
                .clipped()
            
        }
        else {
           
            Rectangle()
                .fill(placeholderColor)
                .frame(width: imageSize.width, height: imageSize.height)
        }
    }
}

struct OptionalImage_Previews: PreviewProvider {
    
    static var previews: some View {
        
        ZStack {
            
            Rectangle()
                .fill(.pink)
            
            OptionalImage(image: nil, imageSize: .fixed(width: 300, height: 150), contentMode: .fill, placeholderColor: .blue)
        }
    }
}
