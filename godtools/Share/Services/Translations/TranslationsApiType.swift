//
//  TranslationsApiType.swift
//  godtools
//
//  Created by Levi Eggert on 4/20/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

protocol TranslationsApiType {
    
    func getTranslationZipData(translationId: String, complete: @escaping ((_ response: RequestResponse, _ result: RequestResult<Data, Error>) -> Void)) -> OperationQueue
}
