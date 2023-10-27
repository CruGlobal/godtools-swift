//
//  LessonFeedbackAnalytics.swift
//  godtools
//
//  Created by Levi Eggert on 10/4/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

class LessonFeedbackAnalytics {
    
    private static let trackLessonFeedbackActionName: String = "lesson_feedback"
    private static let propertyHelpful: String = "helpful"
    private static let propertyReadiness: String = "readiness"
    private static let propertyPageReached: String = "page_reached"
    private static let valueHelpfulYes: String = "yes"
    private static let valueHelpfulNo: String = "no"
    
    private let firebaseAnalytics: FirebaseAnalytics
    
    required init(firebaseAnalytics: FirebaseAnalytics) {
        
        self.firebaseAnalytics = firebaseAnalytics
    }
    
    func trackLessonFeedback(lesson: ResourceModel, feedback: TrackLessonFeedbackDomainModel) {
            
        var data: [String: String] = Dictionary()
        
        if let feedbackHelpful = feedback.feedbackHelpful {
            
            let feedbackHelpfulValue: String
            
            switch feedbackHelpful {
            case .no:
                feedbackHelpfulValue = LessonFeedbackAnalytics.valueHelpfulNo
            case .yes:
                feedbackHelpfulValue = LessonFeedbackAnalytics.valueHelpfulYes
            }
            
            data[LessonFeedbackAnalytics.propertyHelpful] = feedbackHelpfulValue
        }
        
        data[LessonFeedbackAnalytics.propertyReadiness] = String(feedback.readinessScaleValue)
        data[LessonFeedbackAnalytics.propertyPageReached] = String(feedback.pageIndexReached)
        
        firebaseAnalytics.trackAction(
            screenName: "",
            siteSection: lesson.abbreviation,
            siteSubSection: "",
            contentLanguage: nil,
            secondaryContentLanguage: nil,
            actionName: LessonFeedbackAnalytics.trackLessonFeedbackActionName,
            data: data
        )
    }
}
