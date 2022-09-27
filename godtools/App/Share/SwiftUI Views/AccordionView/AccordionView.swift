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
        
        VStack(alignment: .leading, spacing: 15) {
            
            SeparatorView()
            
            HStack {
                Text("Conversation Starters")
                    .font(FontLibrary.sfProTextBold.font(size: 14))
                    .foregroundColor(ColorPalette.gtGrey.color)
                
                Spacer()
                
                Image(viewModel.isExpanded ? "accordion_section_minus" : "accordion_section_plus")
                    .padding(.trailing, 15)
                
            }
            
            SeparatorView()
        }
        .onTapGesture {
            viewModel.isExpanded.toggle()
        }
        .animation(.default, value: viewModel.isExpanded)
    }
}

struct AccordionView_Previews: PreviewProvider {
    static var previews: some View {
        AccordionView(viewModel: AccordionViewModel())
            .padding()
    }
}
