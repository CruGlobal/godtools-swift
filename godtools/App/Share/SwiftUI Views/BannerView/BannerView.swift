//
//  BannerView.swift
//  godtools
//
//  Created by Rachael Skeath on 6/25/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

struct BannerView<Content: View>: View {
        
    let content: () -> Content
    let closeButtonTapHandler: () -> Void
        
    var body: some View {
        ZStack(alignment: .topTrailing) {
            ColorPalette.banner.color
            
            HStack {
                Spacer()
                
                content()
                    .padding([.top, .bottom], 30)
                    .padding([.leading, .trailing], 45)
                
                Spacer()
            }
            
            Image(ImageCatalog.navClose.name)
                .padding(.trailing, 4)
                .frame(width: 44, height: 44)
                .onTapGesture {
                    withAnimation {
                        closeButtonTapHandler()
                    }
                }
        }
        .fixedSize(horizontal: false, vertical: true)
    }
}

struct BannerView_Previews: PreviewProvider {
    static var previews: some View {
        
        BannerView(content: {
            
            Text("this is a test message")
                .modifier(BannerTextStyle())
            
        }, closeButtonTapHandler: {
            
        })
            .frame(width: 375)
            .previewLayout(.sizeThatFits)
    }
}
