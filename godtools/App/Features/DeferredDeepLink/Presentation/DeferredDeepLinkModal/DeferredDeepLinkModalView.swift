//
//  DeferredDeepLinkModalView.swift
//  godtools
//
//  Created by Rachael Skeath on 8/27/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import SwiftUI

struct DeferredDeepLinkModalView: View {
    var body: some View {
        VStack {
            
            Text("It looks like you clicked a link for GodTools")
            
            Text("Please tap the paste button below.  This will allow us to take you to the content you requested in GodTools.")
            
            HStack {
                GTBlueButton(title: "Paste", width: 150, height: 48) {
                    
                }
                
                GTWhiteButton(title: "Cancel", width: 150, height: 48) {
                    
                }
            }
        }
    }
}

#Preview {
    DeferredDeepLinkModalView()
}
