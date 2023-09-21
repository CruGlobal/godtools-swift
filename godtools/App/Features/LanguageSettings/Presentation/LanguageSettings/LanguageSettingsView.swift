//
//  LanguageSettingsView.swift
//  godtools
//
//  Created by Levi Eggert on 9/21/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import SwiftUI

struct LanguageSettingsView: View {
    
    @ObservedObject private var viewModel: LanguageSettingsViewModel
                
    init(viewModel: LanguageSettingsViewModel) {
        self.viewModel = viewModel
    }
        
    var body: some View {
        
        GeometryReader { geometry in
            
            VStack(alignment: .leading, spacing: 0) {
                
            }
        }
    }
}
