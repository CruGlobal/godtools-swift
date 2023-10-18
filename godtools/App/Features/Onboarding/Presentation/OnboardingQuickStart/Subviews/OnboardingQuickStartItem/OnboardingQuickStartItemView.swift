//
//  OnboardingQuickStartItemView.swift
//  godtools
//
//  Created by Levi Eggert on 3/13/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import SwiftUI

struct OnboardingQuickStartItemView: View {
    
    private let domainModel: OnboardingQuickStartLinkDomainModel
    private let backgroundColor: Color = Color.getColorWithRGB(red: 244, green: 244, blue: 244, opacity: 1)
    
    let geometry: GeometryProxy
    let itemTappedClosure: (() -> Void)
    
    init(domainModel: OnboardingQuickStartLinkDomainModel, geometry: GeometryProxy, itemTappedClosure: @escaping (() -> Void)) {
        
        self.domainModel = domainModel
        self.geometry = geometry
        self.itemTappedClosure = itemTappedClosure
    }
    
    var body: some View {
        
        ZStack(alignment: .leading) {
                            
            VStack(alignment: .leading, spacing: 0) {
                
                Text(domainModel.title)
                    .multilineTextAlignment(.leading)
                    .foregroundColor(ColorPalette.gtGrey.color)
                    .font(FontLibrary.sfProTextLight.font(size: 19))
                                
                HStack(alignment: .center, spacing: 8) {
                    
                    Text(domainModel.actionTitle)
                        .multilineTextAlignment(.leading)
                        .foregroundColor(ColorPalette.gtBlue.color)
                        .font(FontLibrary.sfProTextSemibold.font(size: 16))
                    
                    ImageCatalog.rightArrowBlue.image
                        .resizable()
                        .scaledToFit()
                        .frame(width: 12, height:12)
                        .clipped()
                        .flipVertically(shouldFlip: ApplicationLayout.shared.layoutDirection == .rightToLeft)
                }
                .padding(EdgeInsets(top: 5, leading: 0, bottom: 0, trailing: 0) )
            }
            .padding(EdgeInsets(top: 12, leading: 12, bottom: 12, trailing: 12))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(backgroundColor)
        .onTapGesture {
            itemTappedClosure()
        }
    }
}
