import AppKit
import Combine
import Foundation

/// Holds the countdown settings (persisted in UserDefaults) and keeps "now" fresh
/// so the menu bar label rolls over at midnight.
@MainActor
final class CountdownStore: ObservableObject {
    private enum Key {
        static let targetDate = "targetDate"
        static let title = "title"
        static let showTitle = "showTitle"
    }

    private let defaults: UserDefaults
    private var timer: Timer?
    private var observers: [NSObjectProtocol] = []

    @Published var targetDate: Date {
        didSet { defaults.set(targetDate.timeIntervalSince1970, forKey: Key.targetDate) }
    }

    @Published var title: String {
        didSet { defaults.set(title, forKey: Key.title) }
    }

    @Published var showTitle: Bool {
        didSet { defaults.set(showTitle, forKey: Key.showTitle) }
    }

    @Published private(set) var now = Date()

    init(defaults: UserDefaults = .standard, now: Date = Date()) {
        self.defaults = defaults
        self.now = now
        let calendar = Calendar.current
        if defaults.object(forKey: Key.targetDate) != nil {
            targetDate = Date(timeIntervalSince1970: defaults.double(forKey: Key.targetDate))
        } else {
            // First launch: default to 30 days from today.
            targetDate = calendar.date(byAdding: .day, value: 30, to: calendar.startOfDay(for: now))!
        }
        title = defaults.string(forKey: Key.title) ?? ""
        showTitle = defaults.object(forKey: Key.showTitle) as? Bool ?? true

        // Refresh every minute; also refresh on day change and wake from sleep.
        timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            Task { @MainActor in self?.now = Date() }
        }
        let refresh: @Sendable (Notification) -> Void = { [weak self] _ in
            Task { @MainActor in self?.now = Date() }
        }
        observers.append(NotificationCenter.default.addObserver(
            forName: .NSCalendarDayChanged, object: nil, queue: .main, using: refresh))
        observers.append(NSWorkspace.shared.notificationCenter.addObserver(
            forName: NSWorkspace.didWakeNotification, object: nil, queue: .main, using: refresh))
    }

    /// Calendar days from today to the target date (negative once it has passed).
    var daysRemaining: Int {
        Self.days(from: now, to: targetDate)
    }

    var countdownText: String {
        Self.countdownText(days: daysRemaining)
    }

    nonisolated static func days(from: Date, to: Date, calendar: Calendar = .current) -> Int {
        let start = calendar.startOfDay(for: from)
        let end = calendar.startOfDay(for: to)
        return calendar.dateComponents([.day], from: start, to: end).day ?? 0
    }

    nonisolated static func countdownText(days: Int) -> String {
        switch days {
        case 0: return "Today"
        case 1: return "1 day"
        case let d where d > 1: return "\(d) days"
        case -1: return "1 day ago"
        default: return "\(-days) days ago"
        }
    }

    var menuBarTitle: String {
        let name = title.trimmingCharacters(in: .whitespaces)
        if showTitle && !name.isEmpty {
            return "\(name): \(countdownText)"
        }
        return countdownText
    }
}
