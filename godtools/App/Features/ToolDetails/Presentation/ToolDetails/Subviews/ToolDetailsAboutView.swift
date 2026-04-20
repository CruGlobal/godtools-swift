//
//  ToolDetailsAboutView.swift
//  godtools
//
//  Created by Levi Eggert on 6/9/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

struct ToolDetailsAboutView: View {
           
    private let geometry: GeometryProxy
    
    @ObservedObject private var viewModel: ToolDetailsViewModel
        
    @State private var accordionExpandedConversationStarters: Bool = false
    @State private var accordionExpandedOutline: Bool = false
    @State private var accordionExpandedBibleReferences: Bool = false
    @State private var accordionExpandedLanguageAvailability: Bool = false
    
    init(viewModel: ToolDetailsViewModel, geometry: GeometryProxy) {
        
        self.viewModel = viewModel
        self.geometry = geometry
    }
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 0) {
            
            ToolDetailsSectionDescriptionTextView(
                viewModel: viewModel,
                geometry: geometry,
                text: viewModel.toolDetails.aboutDescription
            )
            
            Rectangle()
                .frame(height: 20)
                .foregroundColor(.clear)
            
            VStack(spacing: 20) {
                
                if viewModel.toolDetails.conversationStarters.isEmpty == false {
                    
                    AccordionView(title: viewModel.strings.conversationStartersTitle, contents: viewModel.toolDetails.conversationStarters, isExpanded: $accordionExpandedConversationStarters)
                }
                
                if viewModel.outlineContent.isEmpty == false {
                    
                    AccordionView(title: viewModel.strings.outlineTitle, contents: viewModel.outlineContent, isExpanded: $accordionExpandedOutline)
                }

                if viewModel.toolDetails.bibleReferences.isEmpty == false {
                    
                    AccordionView(title: viewModel.strings.bibleReferencesTitle, contents: viewModel.toolDetails.bibleReferences, isExpanded: $accordionExpandedBibleReferences)
                }
                
                if viewModel.toolDetails.languagesAvailable.isEmpty == false {
                    
                    AccordionView(title: viewModel.strings.languagesAvailableTitle, contents: viewModel.toolDetails.languagesAvailable, isExpanded: $accordionExpandedLanguageAvailability)
                }
            }
            .padding(ToolDetailsView.sectionDescriptionTextInsets)
            
            if accordionExpandedConversationStarters || accordionExpandedOutline || accordionExpandedBibleReferences || accordionExpandedLanguageAvailability {
                Spacer()
            } else {
                Rectangle()
                    .frame(height: 100)
                    .foregroundColor(.clear)
            }
        }
    }
}
