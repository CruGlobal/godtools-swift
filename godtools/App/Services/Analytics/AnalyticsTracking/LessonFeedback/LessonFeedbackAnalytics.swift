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
    
    func trackLessonFeedback(siteSection: String, feedbackHelpful: LessonFeedbackHelpful?, readinessScaleValue: Int, pageIndexReached: Int) {
            
        var data: [String: String] = Dictionary()
        
        if let feedbackHelpful = feedbackHelpful {
            
            let feedbackHelpfulValue: String
            
            switch feedbackHelpful {
            case .yes:
                feedbackHelpfulValue = LessonFeedbackAnalytics.valueHelpfulYes
                
            case .no:
                feedbackHelpfulValue = LessonFeedbackAnalytics.valueHelpfulNo
            }
            
            data[LessonFeedbackAnalytics.propertyHelpful] = feedbackHelpfulValue
        }
        
        data[LessonFeedbackAnalytics.propertyReadiness] = String(readinessScaleValue)
        data[LessonFeedbackAnalytics.propertyPageReached] = String(pageIndexReached)
        
        firebaseAnalytics.trackAction(
            screenName: "",
            siteSection: siteSection,
            siteSubSection: "",
            contentLanguage: nil,
            secondaryContentLanguage: nil,
            actionName: LessonFeedbackAnalytics.trackLessonFeedbackActionName,
            data: data
        )
    }
}
