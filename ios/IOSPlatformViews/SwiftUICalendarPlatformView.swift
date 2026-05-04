import Flutter
import UIKit
import CalendarKit
import EventKit
import EventKitUI

class SwiftUICalendarPlatformView: NSObject, FlutterPlatformView {
    private let navController: UINavigationController
    private let controller: CalendarViewController
    private let methodChannel: FlutterMethodChannel

    init(frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?, binaryMessenger: FlutterBinaryMessenger) {
        controller = CalendarViewController()
        navController = UINavigationController(rootViewController: controller)
        methodChannel = FlutterMethodChannel(
            name: "ios-calendar-view/methods_\(viewId)",
            binaryMessenger: binaryMessenger
        )
        super.init()
        navController.view.frame = frame
        navController.view.backgroundColor = UIColor.clear

        if let arguments = args as? [String: Any],
           let initialSelectedDate = arguments["initialSelectedDate"] as? String {
            controller.setSelectedDate(fromISO8601: initialSelectedDate)
        }

        methodChannel.setMethodCallHandler { [weak self] call, result in
            guard let self else {
                result(FlutterError(code: "deallocated", message: "Calendar view was deallocated", details: nil))
                return
            }
            switch call.method {
            case "setSelectedDate":
                guard let payload = call.arguments as? [String: Any],
                      let value = payload["date"] as? String else {
                    result(FlutterError(code: "bad_args", message: "Expected {date: ISO8601 string}", details: nil))
                    return
                }
                self.controller.setSelectedDate(fromISO8601: value)
                result(nil)
            default:
                result(FlutterMethodNotImplemented)
            }
        }
    }

    func view() -> UIView {
        navController.view
    }
}

final class CalendarViewController: DayViewController, EKEventEditViewDelegate {
    private var eventStore = EKEventStore()
    private var hasSubscribed = false
    private let arabicLocale = Locale(identifier: "ar_SA")
    override func viewDidLoad() {
        super.viewDidLoad()
        title = todayTitle
        dayView.autoScrollToFirstEvent = true
        view.semanticContentAttribute = .forceRightToLeft
        dayView.semanticContentAttribute = .forceRightToLeft
        requestAccessToCalendar()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setToolbarHidden(true, animated: false)
    }

    private func requestAccessToCalendar() {
        let completionHandler: EKEventStoreRequestAccessCompletionHandler = { [weak self] granted, _ in
            DispatchQueue.main.async {
                guard let self else { return }
                self.initializeStore()
                self.subscribeToNotifications()
                if granted {
                    self.reloadData()
                    self.title = self.todayTitle
                }
            }
        }

        if #available(iOS 17.0, *) {
            eventStore.requestFullAccessToEvents(completion: completionHandler)
        } else {
            eventStore.requestAccess(to: .event, completion: completionHandler)
        }
    }

    private func subscribeToNotifications() {
        guard !hasSubscribed else { return }
        hasSubscribed = true
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(storeChanged(_:)),
            name: .EKEventStoreChanged,
            object: eventStore
        )
    }

    private func initializeStore() {
        eventStore = EKEventStore()
    }

    @objc private func storeChanged(_ notification: Notification) {
        reloadData()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func eventsForDate(_ date: Date) -> [EventDescriptor] {
        let startDate = calendar.startOfDay(for: date)
        guard let endDate = calendar.date(byAdding: .day, value: 1, to: startDate) else {
            return []
        }
        let predicate = eventStore.predicateForEvents(withStart: startDate, end: endDate, calendars: nil)
        let eventKitEvents = eventStore.events(matching: predicate)
        return eventKitEvents.map(EKWrapper.init)
    }

    override func dayViewDidSelectEventView(_ eventView: EventView) {
        guard let ckEvent = eventView.descriptor as? EKWrapper else {
            return
        }
        presentDetailViewForEvent(ckEvent.ekEvent)
    }

    private func presentDetailViewForEvent(_ ekEvent: EKEvent) {
        let eventController = EKEventViewController()
        eventController.event = ekEvent
        eventController.allowsCalendarPreview = true
        eventController.allowsEditing = true
        navigationController?.pushViewController(eventController, animated: true)
    }

    override func dayView(dayView: DayView, didLongPressTimelineAt date: Date) {
        endEventEditing()
        let newEKWrapper = createNewEvent(at: date)
        create(event: newEKWrapper, animated: true)
    }

    private func createNewEvent(at date: Date) -> EKWrapper {
        let newEKEvent = EKEvent(eventStore: eventStore)
        newEKEvent.calendar = eventStore.defaultCalendarForNewEvents
        newEKEvent.startDate = date
        newEKEvent.endDate = calendar.date(byAdding: .hour, value: 1, to: date)
        newEKEvent.title = "حدث جديد"

        let wrapper = EKWrapper(eventKitEvent: newEKEvent)
        wrapper.editedEvent = wrapper
        return wrapper
    }

    override func dayViewDidLongPressEventView(_ eventView: EventView) {
        guard let descriptor = eventView.descriptor as? EKWrapper else {
            return
        }
        endEventEditing()
        beginEditing(event: descriptor, animated: true)
    }

    override func dayView(dayView: DayView, didUpdate event: EventDescriptor) {
        guard let editingEvent = event as? EKWrapper else { return }
        if let originalEvent = event.editedEvent {
            editingEvent.commitEditing()
            if originalEvent === editingEvent {
                presentEditingViewForEvent(editingEvent.ekEvent)
            } else {
                try? eventStore.save(editingEvent.ekEvent, span: .thisEvent)
            }
        }
        reloadData()
    }

    private func presentEditingViewForEvent(_ ekEvent: EKEvent) {
        let controller = EKEventEditViewController()
        controller.event = ekEvent
        controller.eventStore = eventStore
        controller.editViewDelegate = self
        present(controller, animated: true)
    }

    override func dayView(dayView: DayView, didTapTimelineAt date: Date) {
        endEventEditing()
    }

    override func dayViewDidBeginDragging(dayView: DayView) {
        endEventEditing()
    }

    func eventEditViewController(_ controller: EKEventEditViewController, didCompleteWith action: EKEventEditViewAction) {
        endEventEditing()
        reloadData()
        controller.dismiss(animated: true)
    }

    func setSelectedDate(fromISO8601 value: String) {
        guard let selectedDate = Date.fromISO8601(value) else { return }
        move(to: selectedDate)
        title = dateTitle(for: selectedDate)
        reloadData()
    }
}

final class EKWrapper: EventDescriptor {
    let ekEvent: EKEvent

    var editedEvent: EventDescriptor?
    var dateInterval: DateInterval
    var text: String
    var attributedText: NSAttributedString?
    var lineBreakMode: NSLineBreakMode?
    var color: UIColor
    var backgroundColor: UIColor
    var textColor: UIColor
    var font: UIFont = .systemFont(ofSize: 12)
    var userInfo: Any?
    var isAllDay: Bool

    init(eventKitEvent: EKEvent) {
        self.ekEvent = eventKitEvent
        let title = eventKitEvent.title ?? ""
        self.dateInterval = DateInterval(start: eventKitEvent.startDate, end: eventKitEvent.endDate)
        self.text = title
        self.attributedText = NSAttributedString(string: title)
        self.lineBreakMode = .byWordWrapping
        let calColor = UIColor(cgColor: eventKitEvent.calendar.cgColor)
        self.color = calColor
        self.backgroundColor = calColor.withAlphaComponent(0.3)
        self.textColor = .label
        self.isAllDay = eventKitEvent.isAllDay
    }

    convenience init(eventKitEvent: EKEvent, dateInterval: DateInterval) {
        self.init(eventKitEvent: eventKitEvent)
        self.dateInterval = dateInterval
    }

    func makeEditable() -> Self {
        return self
    }

    func commitEditing() {
        ekEvent.title = text
        ekEvent.startDate = dateInterval.start
        ekEvent.endDate = dateInterval.end
        ekEvent.isAllDay = isAllDay
    }
}

private extension CalendarViewController {
    var todayTitle: String {
        dateTitle(for: Date())
    }

    func dateTitle(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = arabicLocale
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.setLocalizedDateFormatFromTemplate("EEEE d MMMM yyyy")
        return formatter.string(from: date)
    }
}

private extension Date {
    static func fromISO8601(_ value: String) -> Date? {
        let withFractionalSeconds = ISO8601DateFormatter()
        withFractionalSeconds.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let parsed = withFractionalSeconds.date(from: value) {
            return parsed
        }
        let basic = ISO8601DateFormatter()
        basic.formatOptions = [.withInternetDateTime]
        return basic.date(from: value)
    }
}