
import UIKit
import CalendarKit
import EventKit
import EventKitUI

final class CalendarViewController: DayViewController, EKEventEditViewDelegate {
    private var eventStore = EKEventStore()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "التقويم"
        // التطبيق يحتاج إذن للوصول إلى التقويم لعرض الأحداث
        requestAccessToCalendar()
        // الاشتراك في الإشعارات لتحديث الشاشة عند تغيير البيانات
        subscribeToNotifications()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setToolbarHidden(true, animated: false)
    }

    private func requestAccessToCalendar() {
        let completionHandler: EKEventStoreRequestAccessCompletionHandler = { [weak self] granted, error in
            DispatchQueue.main.async {
                guard let self else { return }
                self.initializeStore()
                self.subscribeToNotifications()
                self.reloadData()
            }
        }

        if #available(iOS 17.0, *) {
            eventStore.requestFullAccessToEvents(completion: completionHandler)
        } else {
            eventStore.requestAccess(to: .event, completion: completionHandler)
        }
    }

    private func subscribeToNotifications() {
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

    override func eventsForDate(_ date: Date) -> [EventDescriptor] {
        let startDate = date
        var oneDay = DateComponents()
        oneDay.day = 1
        let endDate = calendar.date(byAdding: oneDay, to: startDate)!

        let predicate = eventStore.predicateForEvents(
            withStart: startDate,
            end: endDate,
            calendars: nil
        )

        let eventKitEvents = eventStore.events(matching: predicate)
        return eventKitEvents.map(EKWrapper.init)
    }

    override func dayViewDidSelectEventView(_ eventView: EventView) {
        guard let ckEvent = eventView.descriptor as? EKWrapper else { return }
        presentDetailViewForEvent(ckEvent.ekEvent)
    }

    private func presentDetailViewForEvent(_ ekEvent: EKEvent) {
        let vc = EKEventViewController()
        vc.event = ekEvent
        vc.allowsCalendarPreview = true
        vc.allowsEditing = true
        navigationController?.pushViewController(vc, animated: true)
    }

    override func dayView(dayView: DayView, didLongPressTimelineAt date: Date) {
        endEventEditing()
        let newEvent = createNewEvent(at: date)
        create(event: newEvent, animated: true)
    }

    private func createNewEvent(at date: Date) -> EKWrapper {
        let ev = EKEvent(eventStore: eventStore)
        ev.calendar = eventStore.defaultCalendarForNewEvents

        var comp = DateComponents()
        comp.hour = 1
        let end = calendar.date(byAdding: comp, to: date)

        ev.startDate = date
        ev.endDate = end
        ev.title = "حدث جديد"

        let wrap = EKWrapper(eventKitEvent: ev)
        wrap.editedEvent = wrap
        return wrap
    }

    override func dayViewDidLongPressEventView(_ eventView: EventView) {
        guard let descriptor = eventView.descriptor as? EKWrapper else { return }
        endEventEditing()
        beginEditing(event: descriptor, animated: true)
    }

    override func dayView(dayView: DayView, didUpdate event: EventDescriptor) {
        guard let editing = event as? EKWrapper else { return }
        if let original = event.editedEvent {
            editing.commitEditing()
            if original === editing {
                presentEditingViewForEvent(editing.ekEvent)
            } else {
                try? eventStore.save(editing.ekEvent, span: .thisEvent)
            }
        }
        reloadData()
    }

    private func presentEditingViewForEvent(_ ekEvent: EKEvent) {
        let editVC = EKEventEditViewController()
        editVC.event = ekEvent
        editVC.eventStore = eventStore
        editVC.editViewDelegate = self
        present(editVC, animated: true)
    }
}
