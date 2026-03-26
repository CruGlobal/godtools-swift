//
//  QRCodeModalView.swift
//  godtools
//
//  Created by Levi Eggert on 3/22/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import SwiftUI

struct QRCodeModalView: View {
    
    private let shareUrl: String
    private let qrCodeDescription: String
    private let closeButtonTitle: String
    private let closeTapped: (() -> Void)?
    
    @State private var modalIsHidden: Bool = true
    
    init(shareUrl: String, qrCodeDescription: String, closeButtonTitle: String, closeTapped: (() -> Void)?) {
        
        self.shareUrl = shareUrl
        self.qrCodeDescription = qrCodeDescription
        self.closeButtonTitle = closeButtonTitle
        self.closeTapped = closeTapped
    }
    
    var body: some View {
        
        GTModalView (content: { geometry in
            
            VStack {
                HStack {
                    Spacer()
                    
                    CloseButton {
                        closeTapped?()
                    }
                    .padding(.top, 20)
                    .padding(.trailing, 25)
                }
                
                QRCodeView(data: Data(shareUrl.utf8))
                    .frame(width: 200, height: 200)
                    .padding(.top, 53)
                    .padding(.bottom, 20)
                
                Text(qrCodeDescription)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 25)
                    .padding(.horizontal, 70)
                                
                GTBlueButton(title: closeButtonTitle, font: FontLibrary.sfProDisplayRegular.font(size: 16), width: 150, height: 48) {
                    
                    modalIsHidden = true
                    closeTapped?()
                }
                .padding(.bottom, 125)
            }
            
        }, isHidden: $modalIsHidden, overlayTappedClosure: {
            
            closeTapped?()
        })
        .environment(\.layoutDirection, ApplicationLayout.shared.layoutDirection)
    }
}
