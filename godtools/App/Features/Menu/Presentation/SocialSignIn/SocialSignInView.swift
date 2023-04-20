//
//  SocialSignInView.swift
//  godtools
//
//  Created by Rachael Skeath on 4/20/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import SwiftUI

struct SocialSignInView: View {
    var body: some View {
        
        GeometryReader { geometry in
            
            ZStack {
                ColorPalette.gtBlue.color
                    .ignoresSafeArea()
                
                VStack {
                    
                    Image(ImageCatalog.loginBackground.rawValue)
                        .resizable()
                        .scaledToFit()
                        .frame(width: geometry.size.width)
                    
                    Text("Sign in")
                }
                
            }
            
        }
        
    }
}

struct SocialSignInView_Previews: PreviewProvider {
    static var previews: some View {
        SocialSignInView()
            .previewLayout(.device)
    }
}
