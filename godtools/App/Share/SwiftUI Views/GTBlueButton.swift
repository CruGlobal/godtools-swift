//
//  GTBlueButton.swift
//  godtools
//
//  Created by Rachael Skeath on 6/21/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

struct GTBlueButton: View {
    
    let title: String
    let fontSize: CGFloat
    let width: CGFloat?
    let height: CGFloat?
    let cornerRadius: CGFloat
    let action: () -> Void
    
    init(title: String, fontSize: CGFloat = 12, width: CGFloat? = nil, height: CGFloat? = nil, cornerRadius: CGFloat = 6, action: @escaping () -> Void) {
        self.title = title
        self.fontSize = fontSize
        self.width = width
        self.height = height
        self.cornerRadius = cornerRadius
        self.action = action
    }
    
    var body: some View {
        
        Button(action: {
            action()
        }) {
            
            ZStack(alignment: .center) {
                
                Rectangle()
                    .fill(.clear)
                    .frame(width: width, height: height)
                    .cornerRadius(cornerRadius)
                
                Text(title)
                    .font(FontLibrary.sfProTextRegular.font(size: fontSize))
                    .foregroundColor(Color.white)
            }
        }
        .frame(width: width, height: height, alignment: .center)
        .background(ColorPalette.gtBlue.color)
        .cornerRadius(cornerRadius)
    }
}

struct GTBlueButton_Previews: PreviewProvider {
    static var previews: some View {
        GTBlueButton(title: "Test Button", cornerRadius: 6, action: {})
            .padding()
            .previewLayout(.sizeThatFits)
    }
}
