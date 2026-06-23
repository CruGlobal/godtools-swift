//
//  CircledTextView.swift
//  godtools
//
//  Created by Levi Eggert on 10/26/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import SwiftUI

struct CircledTextView: View {
    
    private let backgroundColor: Color
    private let tintColor: Color
    private let text: String
    private let lineWidth: CGFloat
    private let size: CGSize
    
    init(
        backgroundColor: Color,
        tintColor: Color,
        text: String,
        lineWidth: CGFloat = 1,
        size: CGSize = CGSize(width: 50, height: 50)
    ) {
        
        self.backgroundColor = backgroundColor
        self.tintColor = tintColor
        self.text = text
        self.lineWidth = lineWidth
        self.size = size
    }
    
    var body: some View {
        
        ZStack(alignment: .center) {
            
            Circle()
                .fill(backgroundColor)
                .frame(width: size.width, height: size.height, alignment: .leading)

            Circle()
                .stroke(tintColor, lineWidth: lineWidth)
                .frame(width: size.width, height: size.height)
            
            Text(text)
                .foregroundColor(tintColor)
        }
    }
}

struct CircledTextView_Preview: PreviewProvider {
           
    static var previews: some View {
        
        CircledTextView(
            backgroundColor: .white,
            tintColor: .red,
            text: "4"
        )
    }
}
