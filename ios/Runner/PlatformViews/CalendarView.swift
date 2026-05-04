import SwiftUI
import EventKit

struct CalendarView: View {
    @State private var selectedDate = Date()
    @State private var events: [EKEvent] = []
    @State private var isLoading = true
    @State private var permissionDenied = false

    private let eventStore = EKEventStore()
    private let gregorian = Calendar(identifier: .gregorian)
    private let hijri = Calendar(identifier: .islamicUmmAlQura)
    private let arabicLocale = Locale(identifier: "ar_SA")

    var body: some View {
        VStack(spacing: 0) {
            weekStrip
            Divider()
            dateHeader
            Divider()
            timeline
        }
        .background(Color(.systemBackground))
        .environment(\.layoutDirection, .rightToLeft)
        .onAppear { requestPermissionAndLoad() }
        .onChange(of: selectedDate) { _ in loadEvents() }
    }

    private var weekStrip: some View {
        HStack(spacing: 0) {
            ForEach(weekDates, id: \.self) { date in
                let isSelected = gregorian.isDate(date, inSameDayAs: selectedDate)
                VStack(spacing: 2) {
                    Text(shortArabicWeekday(date))
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.secondary)

                    ZStack {
                        Circle()
                            .fill(isSelected ? Color.red : Color.clear)
                            .frame(width: 46, height: 46)
                        Text(arabicDigits(gregorian.component(.day, from: date)))
                            .font(.system(size: 28, weight: .bold))
                            .foregroundStyle(isSelected ? .white : .primary)
                    }

                    Text(arabicDigits(hijri.component(.day, from: date)))
                        .font(.system(size: 18, weight: .regular))
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .contentShape(Rectangle())
                .onTapGesture { selectedDate = date }
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 10)
    }

    private var dateHeader: some View {
        VStack(spacing: 4) {
            Text(gregorianArabicHeader)
                .font(.system(size: 36, weight: .bold))
            Text("\(hijriArabicHeader) هـ")
                .font(.system(size: 28, weight: .regular))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
    }

    private var timeline: some View {
        ScrollView {
            VStack(spacing: 0) {
                if isLoading {
                    ProgressView("جاري تحميل الأحداث...")
                        .padding(.top, 16)
                        .padding(.bottom, 10)
                }

                if permissionDenied {
                    Text("يرجى السماح بالوصول للتقويم من إعدادات iOS")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.red)
                        .padding(.vertical, 16)
                }

                if !permissionDenied && !isLoading && events.isEmpty {
                    Text("لا توجد أحداث في هذا اليوم")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.secondary)
                        .padding(.vertical, 16)
                }

                ForEach(0...23, id: \.self) { hour in
                    ZStack(alignment: .topLeading) {
                        HStack(spacing: 0) {
                            Text(arabicHourLabel(hour))
                                .font(.system(size: 20))
                                .foregroundStyle(.secondary)
                                .frame(width: 76, alignment: .trailing)

                            Rectangle()
                                .fill(Color(.systemGray4))
                                .frame(height: 1)
                                .padding(.leading, 12)
                        }
                        .frame(height: 90)

                        VStack(alignment: .leading, spacing: 6) {
                            ForEach(Array(eventsFor(hour: hour).enumerated()), id: \.offset) { _, event in
                                eventChip(event)
                            }
                        }
                        .padding(.leading, 14)
                        .padding(.top, 10)
                    }
                }
            }
            .padding(.horizontal, 10)
            .padding(.bottom, 20)
        }
    }

    private func eventChip(_ event: EKEvent) -> some View {
        let title = (event.title ?? "").isEmpty ? "بدون عنوان" : (event.title ?? "")
        return HStack(spacing: 8) {
            Circle()
                .fill(Color.red)
                .frame(width: 8, height: 8)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                Text(eventTimeRange(event))
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    private var weekDates: [Date] {
        guard let weekInterval = gregorian.dateInterval(of: .weekOfYear, for: selectedDate) else {
            return [selectedDate]
        }
        return (0..<7).compactMap { offset in
            gregorian.date(byAdding: .day, value: offset, to: weekInterval.start)
        }
    }

    private var gregorianArabicHeader: String {
        let formatter = DateFormatter()
        formatter.locale = arabicLocale
        formatter.calendar = gregorian
        formatter.setLocalizedDateFormatFromTemplate("EEEE d MMMM yyyy")
        return formatter.string(from: selectedDate)
    }

    private var hijriArabicHeader: String {
        let formatter = DateFormatter()
        formatter.locale = arabicLocale
        formatter.calendar = hijri
        formatter.setLocalizedDateFormatFromTemplate("d MMMM yyyy")
        return formatter.string(from: selectedDate)
    }

    private func shortArabicWeekday(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = arabicLocale
        formatter.setLocalizedDateFormatFromTemplate("EEE")
        return formatter.string(from: date)
    }

    private func arabicDigits(_ value: Int) -> String {
        let formatter = NumberFormatter()
        formatter.locale = arabicLocale
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }

    private func arabicHourLabel(_ hour: Int) -> String {
        var components = DateComponents()
        components.hour = hour
        components.minute = 0
        let date = gregorian.date(from: components) ?? Date()
        let formatter = DateFormatter()
        formatter.locale = arabicLocale
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }

    private func eventTimeRange(_ event: EKEvent) -> String {
        let formatter = DateFormatter()
        formatter.locale = arabicLocale
        formatter.dateFormat = "HH:mm"
        return "\(formatter.string(from: event.startDate)) - \(formatter.string(from: event.endDate))"
    }

    private func eventsFor(hour: Int) -> [EKEvent] {
        let startOfDay = gregorian.startOfDay(for: selectedDate)
        guard let slotStart = gregorian.date(byAdding: .hour, value: hour, to: startOfDay),
              let slotEnd = gregorian.date(byAdding: .hour, value: 1, to: slotStart) else {
            return []
        }

        return events
            .filter { !$0.isAllDay && $0.startDate < slotEnd && $0.endDate > slotStart }
            .sorted { $0.startDate < $1.startDate }
    }

    private func requestPermissionAndLoad() {
        isLoading = true
        if #available(iOS 17.0, *) {
            eventStore.requestFullAccessToEvents { granted, _ in
                DispatchQueue.main.async {
                    permissionDenied = !granted
                    granted ? loadEvents() : finishEmptyState()
                }
            }
        } else {
            eventStore.requestAccess(to: .event) { granted, _ in
                DispatchQueue.main.async {
                    permissionDenied = !granted
                    granted ? loadEvents() : finishEmptyState()
                }
            }
        }
    }

    private func loadEvents() {
        isLoading = true
        let startOfDay = gregorian.startOfDay(for: selectedDate)
        guard let endOfDay = gregorian.date(byAdding: .day, value: 1, to: startOfDay) else {
            finishEmptyState()
            return
        }
        let predicate = eventStore.predicateForEvents(withStart: startOfDay, end: endOfDay, calendars: nil)
        events = eventStore.events(matching: predicate)
        isLoading = false
    }

    private func finishEmptyState() {
        events = []
        isLoading = false
    }
}