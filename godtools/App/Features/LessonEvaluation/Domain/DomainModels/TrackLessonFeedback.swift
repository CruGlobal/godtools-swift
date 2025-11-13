//
//  TrackLessonFeedback.swift
//  godtools
//
//  Created by Levi Eggert on 10/25/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

struct TrackLessonFeedback {
 
    let feedbackHelpful: TrackLessonFeedback.FeedbackHelpful?
    let readinessScaleValue: Int
    let pageIndexReached: Int
    
    static var emptyValue: TrackLessonFeedback {
        return TrackLessonFeedback(feedbackHelpful: nil, readinessScaleValue: 0, pageIndexReached: 0)
    }
}

extension TrackLessonFeedback {
    enum FeedbackHelpful {
        case no
        case yes
    }
}
