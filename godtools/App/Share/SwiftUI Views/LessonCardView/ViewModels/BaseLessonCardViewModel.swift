//
//  BaseLessonCardViewModel.swift
//  godtools
//
//  Created by Rachael Skeath on 6/27/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

class BaseLessonCardViewModel: NSObject, ObservableObject {
    
    // MARK: - Published
    
    @Published var title: String = ""
    @Published var translationAvailableText: String = ""
    @Published var bannerImage: Image?
    @Published var attachmentsDownloadProgressValue: Double = 0
    @Published var translationDownloadProgressValue: Double = 0

    // MARK: - Public Methods
    
    func lessonCardTapped() {}
}
