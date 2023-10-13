//
//  GetInterfaceLayoutDirectionUseCaseTests.swift
//  godtoolsTests
//
//  Created by Levi Eggert on 9/27/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
@testable import godtools
import Combine
import Quick
import Nimble

class GetInterfaceLayoutDirectionUseCaseTests: QuickSpec {
    
    override class func spec() {
        
        describe("User is viewing the app UI layout.") {
         
            context("When the device is in a left to right language and the user preferred language is in the right to left language Arabic.") {
                
                let getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase = GetCurrentAppLanguageUseCase(
                    getAppLanguagesRepositoryInterface: TestsGetAppLanguagesRepository(appLanguagesCodes: [.arabic, .english, .french, .spanish]),
                    getUserPreferredAppLanguageRepositoryInterface: TestsGetUserPreferredAppLanguageRepository(userAppLanguageCode: .arabic),
                    getDeviceAppLanguageRepositoryInterface: TestsGetDeviceLanguageRepository(deviceLanguageCode: .english)
                )
                
                let getAppLanguageRepository = GetAppLanguageRepository(
                    appLanguagesRepository: AppLanguagesRepository()
                )
                
                let getUserPreferredAppLanguageRepository = TestsGetUserPreferredAppLanguageRepository(userAppLanguageCode: .arabic)
                
                let getInterfaceLayoutDirectionUseCase = GetInterfaceLayoutDirectionUseCase(
                    getCurrentAppLanguageUseCase: getCurrentAppLanguageUseCase,
                    getAppLanguageRepositoryInterface: getAppLanguageRepository,
                    getUserPreferredAppLanguageRepositoryInterface: getUserPreferredAppLanguageRepository
                )
                
                it("The application UI should be in a right to left layout.") {
                    
                    waitUntil { done in
                        
                        var layoutDirectionRef: AppInterfaceLayoutDirectionDomainModel?
                        var sinkCompleted: Bool = false
                        
                        _ = getInterfaceLayoutDirectionUseCase.getLayoutDirectionPublisher()
                            .sink { (layoutDirection: AppInterfaceLayoutDirectionDomainModel) in
                                
                                guard !sinkCompleted else {
                                    return
                                }
                                
                                sinkCompleted = true
                                
                                layoutDirectionRef = layoutDirection
                                
                                done()
                            }
                        
                        expect(layoutDirectionRef).to(equal(.rightToLeft))
                    }
                }
            }
            
            context("When the device is in a right to left language and the user preferred language is in the left to right language English.") {
                
                let getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase = GetCurrentAppLanguageUseCase(
                    getAppLanguagesRepositoryInterface: TestsGetAppLanguagesRepository(appLanguagesCodes: [.arabic, .english, .french, .spanish]),
                    getUserPreferredAppLanguageRepositoryInterface: TestsGetUserPreferredAppLanguageRepository(userAppLanguageCode: .english),
                    getDeviceAppLanguageRepositoryInterface: TestsGetDeviceLanguageRepository(deviceLanguageCode: .arabic)
                )
                
                let getAppLanguageRepository = GetAppLanguageRepository(
                    appLanguagesRepository: AppLanguagesRepository()
                )
                
                let getUserPreferredAppLanguageRepository = TestsGetUserPreferredAppLanguageRepository(userAppLanguageCode: .arabic)
                
                let getInterfaceLayoutDirectionUseCase = GetInterfaceLayoutDirectionUseCase(
                    getCurrentAppLanguageUseCase: getCurrentAppLanguageUseCase,
                    getAppLanguageRepositoryInterface: getAppLanguageRepository,
                    getUserPreferredAppLanguageRepositoryInterface: getUserPreferredAppLanguageRepository
                )
                
                it("The application UI should be in a left to right layout.") {
                    
                    waitUntil { done in
                        
                        var layoutDirectionRef: AppInterfaceLayoutDirectionDomainModel?
                        var sinkCompleted: Bool = false
                        
                        _ = getInterfaceLayoutDirectionUseCase.getLayoutDirectionPublisher()
                            .sink { (layoutDirection: AppInterfaceLayoutDirectionDomainModel) in
                                
                                guard !sinkCompleted else {
                                    return
                                }
                                
                                sinkCompleted = true
                                
                                layoutDirectionRef = layoutDirection
                                
                                done()
                            }
                        
                        expect(layoutDirectionRef).to(equal(.leftToRight))
                    }
                }
            }
        }
    }
}
