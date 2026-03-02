//
//  TrackLessonFeedback.swift
//  godtools
//
//  Created by Levi Eggert on 10/25/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

struct TrackLessonFeedbackDomainModel: Sendable {
 
    let feedbackHelpful: TrackLessonFeedbackDomainModel.FeedbackHelpful?
    let readinessScaleValue: Int
    let pageIndexReached: Int
    
    static var emptyValue: TrackLessonFeedbackDomainModel {
        return TrackLessonFeedbackDomainModel(feedbackHelpful: nil, readinessScaleValue: 0, pageIndexReached: 0)
    }
}

extension TrackLessonFeedbackDomainModel {
    enum FeedbackHelpful {
        case no
        case yes
    }
}
