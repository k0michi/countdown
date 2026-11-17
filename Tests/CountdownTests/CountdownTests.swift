import Foundation
import Testing
@testable import Countdown

private func date(_ y: Int, _ m: Int, _ d: Int, hour: Int = 12, calendar: Calendar) -> Date {
    calendar.date(from: DateComponents(year: y, month: m, day: d, hour: hour))!
}

private func makeDefaults() -> UserDefaults {
    let name = "CountdownTests.\(UUID().uuidString)"
    let defaults = UserDefaults(suiteName: name)!
    defaults.removePersistentDomain(forName: name)
    return defaults
}

struct DayCountTests {
    let calendar: Calendar = {
        var c = Calendar(identifier: .gregorian)
        c.timeZone = TimeZone(identifier: "Asia/Tokyo")!
        return c
    }()

    @Test func countsCalendarDaysIgnoringTimeOfDay() {
        let from = date(2026, 11, 17, hour: 23, calendar: calendar)
        let to = date(2026, 11, 18, hour: 0, calendar: calendar)
        #expect(CountdownStore.days(from: from, to: to, calendar: calendar) == 1)
    }

    @Test func sameDayIsZero() {
        let from = date(2026, 11, 17, hour: 0, calendar: calendar)
        let to = date(2026, 11, 17, hour: 23, calendar: calendar)
        #expect(CountdownStore.days(from: from, to: to, calendar: calendar) == 0)
    }

    @Test func pastDateIsNegative() {
        let from = date(2026, 11, 17, calendar: calendar)
        let to = date(2026, 11, 14, calendar: calendar)
        #expect(CountdownStore.days(from: from, to: to, calendar: calendar) == -3)
    }

    @Test func spansYearBoundary() {
        let from = date(2026, 12, 31, calendar: calendar)
        let to = date(2027, 1, 1, calendar: calendar)
        #expect(CountdownStore.days(from: from, to: to, calendar: calendar) == 1)
    }
}

struct CountdownTextTests {
    @Test(arguments: [
        (0, "Today"),
        (1, "1 day"),
        (38, "38 days"),
        (-1, "1 day ago"),
        (-5, "5 days ago"),
    ])
    func formats(days: Int, expected: String) {
        #expect(CountdownStore.countdownText(days: days) == expected)
    }
}

@MainActor
struct PersistenceTests {
    @Test func defaultsToThirtyDaysOnFirstLaunch() {
        let store = CountdownStore(defaults: makeDefaults())
        #expect(store.daysRemaining == 30)
        #expect(store.title == "")
        #expect(store.showTitle)
    }

    @Test func settingsSurviveRelaunch() {
        let defaults = makeDefaults()
        let target = Calendar.current.date(byAdding: .day, value: 10, to: Date())!

        let first = CountdownStore(defaults: defaults)
        first.targetDate = target
        first.title = "Deadline"
        first.showTitle = false

        let second = CountdownStore(defaults: defaults)
        #expect(second.targetDate.timeIntervalSince1970 == target.timeIntervalSince1970)
        #expect(second.title == "Deadline")
        #expect(second.showTitle == false)
        #expect(second.daysRemaining == 10)
        #expect(second.menuBarTitle == "10 days")
    }

    @Test func menuBarTitleIncludesTitle() {
        let store = CountdownStore(defaults: makeDefaults())
        store.title = "Trip"
        #expect(store.menuBarTitle == "Trip: 30 days")
    }
}
