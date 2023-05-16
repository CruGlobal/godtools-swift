//
//  AccountActivityStatView.swift
//  godtools
//
//  Created by Rachael Skeath on 3/20/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import SwiftUI

struct AccountActivityStatView: View {
    
    let stat: UserActivityStatDomainModel
    
    var body: some View {
        
        HStack {
            
            Image(stat.iconImageName)
                .resizable()
                .frame(width: 42, height: 42)
            
            VStack(alignment: .leading, spacing: 0) {
                
                Text(stat.value)
                    .font(FontLibrary.sfProTextSemibold.font(size: 25))
                    .foregroundColor(stat.textColor)
                
                Text(stat.text)
                    .font(FontLibrary.sfProTextRegular.font(size: 10))
                    .foregroundColor(ColorPalette.gtGrey.color)
            }
            
        }
    }
}
