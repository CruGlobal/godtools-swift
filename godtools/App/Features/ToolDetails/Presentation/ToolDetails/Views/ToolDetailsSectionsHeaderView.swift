//
//  ToolDetailsSectionsHeaderView.swift
//  godtools
//
//  Created by Levi Eggert on 6/9/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

struct ToolDetailsSectionsHeaderView: View {
        
    private let buttonHeight: CGFloat = 50
    
    let geometry: GeometryProxy
    
    var body: some View {
        
        ScrollView(.horizontal, showsIndicators: false) {
            
            HStack(alignment: .center, spacing: 30) {
                
                Button(action: {
                    print("button tapped...")
                }) {
                    Text("About")
                        .foregroundColor(Color.black)
                }
                
                Button(action: {
                    print("button tapped...")
                }) {
                    Text("Versions")
                        .foregroundColor(Color.black)
                }
            }
        }
        .frame(width: geometry.size.width, height: buttonHeight, alignment: .center)
    }
}
