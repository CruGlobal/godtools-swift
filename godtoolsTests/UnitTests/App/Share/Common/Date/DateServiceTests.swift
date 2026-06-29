//
//  DateServiceTests.swift
//  godtools
//
//  Created by Levi Eggert on 6/29/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Testing
@testable import godtools
import Foundation

struct DateServiceTests {

    struct TestArgument {
        let calendarIdentifier: Calendar.Identifier
    }

    @Test(arguments: [
            TestArgument(calendarIdentifier: .gregorian),
            TestArgument(calendarIdentifier: .buddhist),
            TestArgument(calendarIdentifier: .japanese),
            TestArgument(calendarIdentifier: .hebrew)
        ]
    )
    func currentYearUsesOptionsCalendarWhenNoCalendarIsInjected(argument: TestArgument) async {

        let calendar: Calendar = Calendar(identifier: argument.calendarIdentifier)

        let dateService: DateService = DateService()

        let year: Int? = dateService.getCurrentYear(options: CalendarOptions(calendar: calendar, localeId: nil))

        let expectedYear: Int? = calendar.dateComponents([.year], from: Date()).year

        #expect(year == expectedYear)
    }

    @Test()
    func injectedCalendarTakesPrecedenceOverOptionsCalendar() async {

        let injectedCalendar: Calendar = Calendar(identifier: .buddhist)
        let optionsCalendar: Calendar = Calendar(identifier: .gregorian)

        let dateService: DateService = DateService(calendar: injectedCalendar)

        let year: Int? = dateService.getCurrentYear(options: CalendarOptions(calendar: optionsCalendar, localeId: nil))

        let expectedYear: Int? = injectedCalendar.dateComponents([.year], from: Date()).year
        let optionsYear: Int? = optionsCalendar.dateComponents([.year], from: Date()).year

        #expect(year == expectedYear)
        #expect(year != optionsYear)
    }

    @Test()
    func currentYearMatchesGregorianYearForDefaultOptions() async {

        let dateService: DateService = DateService()

        let year: Int? = dateService.getCurrentYear(options: CalendarOptions.defaultOptions)

        let expectedYear: Int? = Calendar.current.dateComponents([.year], from: Date()).year

        #expect(year == expectedYear)
    }
}
