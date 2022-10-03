//
//  AccordionView.swift
//  godtools
//
//  Created by Rachael Skeath on 9/27/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

struct AccordionView: View {
        
    let title: String
    let contents: String
    
    @Binding var isExpanded: Bool
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 0) {
            
            SeparatorView()
            
            HStack {
                Text(title)
                    .font(FontLibrary.sfProTextBold.font(size: 14))
                    .foregroundColor(ColorPalette.gtGrey.color)
                
                Spacer()
                
                Image(isExpanded ? ImageCatalog.accordionSectionMinus.name : ImageCatalog.accordionSectionPlus.name)
                    .padding(.trailing, 15)
                
            }
            .padding([.top, .bottom], 15)
            .contentShape(Rectangle())
            .onTapGesture {
                isExpanded.toggle()
            }
            
            if isExpanded {
                Text(contents)
                    .font(FontLibrary.sfProTextRegular.font(size: 15))
                    .foregroundColor(ColorPalette.gtGrey.color)
                    .padding(.bottom, 15)
            }
            
            SeparatorView()
        }
    }
}

struct AccordionView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            AccordionView(
                title: "Title Goes Here",
                contents: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.",
                isExpanded: .constant(false)
            )
                .padding()
            
            Spacer()
        }
    }
}
