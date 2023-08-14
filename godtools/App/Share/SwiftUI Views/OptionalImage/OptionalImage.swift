//
//  OptionalImage.swift
//  godtools
//
//  Created by Rachael Skeath on 4/20/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

struct OptionalImage: View {
    
    let image: Image?
    let width: CGFloat
    let height: CGFloat
    let placeholderColor: Color
    
    init(image: Image?, width: CGFloat, height: CGFloat, placeholderColor: Color = .white) {
        
        self.image = image
        self.width = width
        self.height = height
        self.placeholderColor = placeholderColor
    }
    
    var body: some View {
      
        if let image = image {
            
            image
                .resizable()
                .scaledToFill()
                .frame(width: width, height: height)
                .clipped()
            
        }
        else {
           
            Rectangle()
                .fill(placeholderColor)
                .frame(width: width, height: height)
        }
    }
}

struct OptionalImage_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Rectangle()
                .fill(.pink)
            OptionalImage(image: nil, width: 300, height: 150, placeholderColor: .blue)
        }
    }
}
