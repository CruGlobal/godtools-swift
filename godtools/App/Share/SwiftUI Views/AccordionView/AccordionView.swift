//
//  AccordionView.swift
//  godtools
//
//  Created by Rachael Skeath on 9/27/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

struct AccordionView: View {
    
    // MARK: - Properties
    
    @ObservedObject var viewModel: AccordionViewModel
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 0) {
            
            SeparatorView()
            
            HStack {
                Text(viewModel.sectionTitle)
                    .font(FontLibrary.sfProTextBold.font(size: 14))
                    .foregroundColor(ColorPalette.gtGrey.color)
                
                Spacer()
                
                Image(viewModel.isExpanded ? "accordion_section_minus" : "accordion_section_plus")
                    .padding(.trailing, 15)
                
            }
            .padding([.top, .bottom], 15)
            .onTapGesture {
                viewModel.isExpanded.toggle()
            }
            
            if viewModel.isExpanded {
                Text(viewModel.sectionContents)
                    .font(FontLibrary.sfProTextRegular.font(size: 15))
                    .foregroundColor(ColorPalette.gtGrey.color)
                    .padding(.bottom, 15)
            }
            
            SeparatorView()
        }
        .animation(.default, value: viewModel.isExpanded)
    }
}

struct AccordionView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            
            AccordionView(viewModel: AccordionViewModel())
                .padding()
            
            Spacer()
        }
    }
}
