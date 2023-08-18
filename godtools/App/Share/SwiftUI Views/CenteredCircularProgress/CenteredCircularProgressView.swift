//
//  CenteredCircularProgressView.swift
//  godtools
//
//  Created by Levi Eggert on 8/18/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import SwiftUI

struct CenteredCircularProgressView: View {
    
    let progressColor: Color
    
    init(progressColor: Color) {
        
        self.progressColor = progressColor
    }
    
    var body: some View {
            
        ZStack(alignment: .center) {
            
            VStack(alignment: .center, spacing: 0) {
               
                Spacer()
                
                HStack(alignment: .center, spacing: 0) {
                    
                    Spacer()
                    
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .foregroundColor(progressColor)
                    
                    Spacer()
                }
                
                Spacer()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
