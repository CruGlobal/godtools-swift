//
//  MockAemImportsProvider.swift
//  godtools
//
//  Created by Levi Eggert on 4/21/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

struct MockAemImportsProvider: ArticleAemImportSrcProviderType {
        
    let aemImportSrcs: [String]
    
    init() {
        
        aemImportSrcs = [
            "https://www.cru.org/content/experience-fragments/shared-library/language-masters/en/how-to-know-god/what-is-christianity/does-god-answer-our-prayers-",
            "https://www.cru.org/content/experience-fragments/shared-library/language-masters/en/how-to-know-god/what-is-christianity/can-you-explain-the-trinity--",
            "https://www.cru.org/content/experience-fragments/shared-library/language-masters/en/how-to-know-god/what-is-christianity/who-is-the-holy-spirit-",
            "https://www.cru.org/content/experience-fragments/shared-library/language-masters/en/how-to-know-god/what-is-christianity/beyond-blind-faith",
            "https://www.cru.org/content/experience-fragments/shared-library/language-masters/en/how-to-know-god/changed-life-stories/how-an-atheist-found-god",
            "https://www.cru.org/content/experience-fragments/shared-library/language-masters/en/how-to-know-god/what-is-christianity/why-did-jesus-die-",
            "https://www.cru.org/content/experience-fragments/shared-library/language-masters/en/how-to-know-god/obstacles-to-faith/where-is-god-in-the-midst-of-tragedy-",
            "https://www.cru.org/content/experience-fragments/shared-library/language-masters/en/how-to-know-god/what-about-other-religions/connecting-with-the-divine",
            "https://www.cru.org/content/experience-fragments/shared-library/language-masters/en/how-to-know-god/obstacles-to-faith/why-is-life-so-hard-",
            "https://www.cru.org/content/experience-fragments/shared-library/language-masters/en/how-to-know-god/what-is-christianity/who-was-jesus-",
            "https://www.cru.org/content/experience-fragments/shared-library/language-masters/en/how-to-know-god/what-about-other-religions/jesus-and-islam",
            "https://www.cru.org/content/experience-fragments/shared-library/language-masters/en/how-to-know-god/gods-existence/who-is-god--",
            "https://www.cru.org/content/experience-fragments/shared-library/language-masters/en/how-to-know-god/life-questions/real-life",
            "https://www.cru.org/content/experience-fragments/shared-library/language-masters/en/how-to-know-god/relationships-and-the-search-for-intimacy/sex-and-the-search-for-intimacy",
            "https://www.cru.org/content/experience-fragments/shared-library/language-masters/en/how-to-know-god/life-questions/what-does-god-expect-of-me-",
            "https://www.cru.org/content/experience-fragments/shared-library/language-masters/en/how-to-know-god/relationships-and-the-search-for-intimacy/gay--lesbian--god-s-love",
            "https://www.cru.org/content/experience-fragments/shared-library/language-masters/en/how-to-know-god/what-is-christianity/why-you-can-believe-the-bible",
            "https://www.cru.org/content/experience-fragments/shared-library/language-masters/en/how-to-know-god/life-questions/what-it-s-like-to-know-god",
            "https://www.cru.org/content/experience-fragments/shared-library/language-masters/en/how-to-know-god/obstacles-to-faith/peace-of-mind-in-an-unstable-world",
            "https://www.cru.org/content/experience-fragments/shared-library/language-masters/en/how-to-know-god/gods-existence/is-there-a-god-/is-there-a-god-"
        ]
    }
}
