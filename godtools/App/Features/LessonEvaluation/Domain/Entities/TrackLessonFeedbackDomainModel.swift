//
//  TrackLessonFeedbackDomainModel.swift
//  godtools
//
//  Created by Levi Eggert on 10/25/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

struct TrackLessonFeedbackDomainModel {
 
    let feedbackHelpful: TrackLessonFeedbackDomainModel.FeedbackHelpful?
    let readinessScaleValue: Int
    let pageIndexReached: Int
}

extension TrackLessonFeedbackDomainModel {
    enum FeedbackHelpful {
        case no
        case yes
    }
}
