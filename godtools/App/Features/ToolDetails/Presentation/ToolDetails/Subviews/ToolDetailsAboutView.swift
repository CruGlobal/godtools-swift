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
                text: viewModel.aboutDetails
            )
            
            Rectangle()
                .frame(height: 20)
                .foregroundColor(.clear)
            
            VStack(spacing: 20) {
                
                if viewModel.conversationStartersContent.isEmpty == false {
                    
                    AccordionView(title: viewModel.conversationStartersTitle, contents: viewModel.conversationStartersContent, isExpanded: $accordionExpandedConversationStarters)
                }
                
                if viewModel.outlineContent.isEmpty == false {
                    
                    AccordionView(title: viewModel.outlineTitle, contents: viewModel.outlineContent, isExpanded: $accordionExpandedOutline)
                }

                if viewModel.bibleReferencesContent.isEmpty == false {
                    
                    AccordionView(title: viewModel.bibleReferencesTitle, contents: viewModel.bibleReferencesContent, isExpanded: $accordionExpandedBibleReferences)
                }
                
                if viewModel.availableLanguagesList.isEmpty == false {
                    
                    AccordionView(title: viewModel.availableLanguagesTitle, contents: viewModel.availableLanguagesList, isExpanded: $accordionExpandedLanguageAvailability)
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
