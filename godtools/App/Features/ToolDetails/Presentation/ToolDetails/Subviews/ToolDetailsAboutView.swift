//
//  ToolDetailsAboutView.swift
//  godtools
//
//  Created by Levi Eggert on 6/9/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

struct ToolDetailsAboutView: View {
           
    @ObservedObject var viewModel: ToolDetailsViewModel
    
    let width: CGFloat
    
    @State private var accordionExpandedConversationStarters: Bool = false
    @State private var accordionExpandedOutline: Bool = false
    @State private var accordionExpandedBibleReferences: Bool = false
    @State private var accordionExpandedLanguageAvailability: Bool = false
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 0) {
            
            TextWithLinks(
                text: viewModel.aboutDetails,
                textColor: ColorPalette.gtGrey.uiColor,
                font: FontLibrary.sfProTextRegular.uiFont(size: 16),
                lineSpacing: 3,
                width: width,
                didInteractWithUrlClosure: { (url: URL) in
                    viewModel.urlTapped(url: url)
                    return true
                }
            )
            
            Rectangle()
                .frame(height: 20)
                .foregroundColor(.clear)
            
            VStack(spacing: 20) {
                AccordionView(title: viewModel.conversationStartersTitle, contents: viewModel.conversationStartersContent, isExpanded: $accordionExpandedConversationStarters)
                
                AccordionView(title: viewModel.outlineTitle, contents: viewModel.outlineContent, isExpanded: $accordionExpandedOutline)

                AccordionView(title: viewModel.bibleReferencesTitle, contents: viewModel.bibleReferencesContent, isExpanded: $accordionExpandedBibleReferences)

                AccordionView(title: viewModel.availableLanguagesTitle, contents: viewModel.availableLanguagesList, isExpanded: $accordionExpandedLanguageAvailability)
            }
            
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
