//
//  FullScreenDownloadProgressView.swift
//  godtools
//
//  Created by Levi Eggert on 10/27/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import SwiftUI

struct FullScreenDownloadProgressView: View {
        
    private let progressBarHeight: CGFloat = 12
    private let progressBarCornerRadius: CGFloat = 6
    private let progressBarHorizontalInsets: CGFloat = 50
    private let downloadMessage: String
    private let downloadProgress: Double
    private let downloadProgressString: String
    
    init(downloadMessage: String, downloadProgress: Double, downloadProgressString: String) {
    
        self.downloadMessage = downloadMessage
        self.downloadProgress = downloadProgress
        self.downloadProgressString = downloadProgressString
    }
    
    var body: some View {
        
        GeometryReader { geometry in
            
            VStack(alignment: .center, spacing: 0) {
                
                Text(downloadMessage)
                    .multilineTextAlignment(.center)
                    .foregroundColor(ColorPalette.gtGrey.color)
                    .font(FontLibrary.sfProTextRegular.font(size: 17))
                    .padding([.top], 140)
                    .padding([.leading, .trailing], 30)
                
                HStack(alignment: .center, spacing: 0) {
                    
                    Spacer()
                    
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .foregroundColor(ColorPalette.gtGrey.color)
                    
                    Spacer()
                }
                .padding([.top], 30)
                
                let progressBarWidth: CGFloat = geometry.size.width - (progressBarHorizontalInsets * 2)
                
                ZStack(alignment: .leading) {
                    
                    Rectangle()
                        .fill(Color.getColorWithRGB(red: 238, green: 236, blue: 238, opacity: 1))
                        .frame(width: progressBarWidth, height: progressBarHeight)
                        .cornerRadius(6)
                    
                    Rectangle()
                        .fill(ColorPalette.gtBlue.color)
                        .frame(width: getProgressBarDownloadWidth(downloadProgress: downloadProgress, progressBarWidth: progressBarWidth), height: progressBarHeight)
                        .cornerRadius(6)
                }
                .padding([.top], 30)
                .padding([.leading, .trailing], progressBarHorizontalInsets)
                
                Text(downloadProgressString)
                    .multilineTextAlignment(.center)
                    .foregroundColor(ColorPalette.gtGrey.color)
                    .font(FontLibrary.sfProTextRegular.font(size: 17))
                    .padding([.top], 15)
            }
        }
        .environment(\.layoutDirection, ApplicationLayout.shared.layoutDirection)
    }
    
    private func getProgressBarDownloadWidth(downloadProgress: Double, progressBarWidth: CGFloat) -> CGFloat {
        
        let width: CGFloat = downloadProgress * progressBarWidth
        
        if width < 0 {
            return 0
        }
        else if width > progressBarWidth {
            return progressBarWidth
        }
        
        return width
    }
}

struct FullScreenDownloadProgressView_Preview: PreviewProvider {
                   
    static var previews: some View {
        
        FullScreenDownloadProgressView(
            downloadMessage: "Download message here...",
            downloadProgress: 0,
            downloadProgressString: ""
        )
    }
}
