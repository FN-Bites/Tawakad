import UIKit
import EventKit
import CalendarKit

// MARK: - EKWrapper (EventDescriptor wrapper around EKEvent)

final class EKWrapper: EventDescriptor {

    // MARK: EventDescriptor properties

    public var dateInterval: DateInterval {
        get { DateInterval(start: ekEvent.startDate, end: ekEvent.endDate) }
        set {
            let start = newValue.start
            let end   = newValue.end
            ekEvent.startDate = start
            ekEvent.endDate   = end
        }
    }

    public var isAllDay: Bool {
        get { ekEvent.isAllDay }
        set { ekEvent.isAllDay = newValue }
    }

    public var text: String {
        get { ekEvent.title ?? "" }
        set { ekEvent.title = newValue }
    }

    public var attributedText: NSAttributedString?
    public var lineBreakMode: NSLineBreakMode?

    public var color: UIColor {
        get {
            UIColor(cgColor: ekEvent.calendar.cgColor)
        }
    }

    public var backgroundColor = UIColor()
    public var textColor = SystemColors.label
    public var font = UIFont.boldSystemFont(ofSize: 14) // 12 إلى 14 لتحسين الوضوح

    public weak var editedEvent: EventDescriptor? {
        didSet { updateColors() }
    }

    public private(set) var ekEvent: EKEvent

    // MARK: Initializers

    public init(eventKitEvent: EKEvent) {
        self.ekEvent = eventKitEvent
        super.init()
        applyStandardColors()
    }

    // MARK: Editing interface

    public func makeEditable() -> Self {
        // نسخة قابلة للتعديل تشير إلى الـ event الأصلي
        let cloned = Self(eventKitEvent: ekEvent)
        cloned.editedEvent = self
        return cloned
    }

    public func commitEditing() {
        guard let edited = editedEvent else { return }
        edited.dateInterval = dateInterval
        // هنا لا نُغيّر ekEvent مباشرة؛ الاحتفاظ بالـ editing في EventDescriptor layer
    }

    // MARK: Color management

    private func updateColors() {
        if editedEvent != nil {
            applyEditingColors()
        } else {
            applyStandardColors()
        }
    }

    private func applyStandardColors() {
        backgroundColor = dynamicStandardBackgroundColor()
        textColor = dynamicStandardTextColor()
    }

    private func applyEditingColors() {
        backgroundColor = color.withAlphaComponent(0.9)
        textColor = .white
    }

    private func dynamicStandardBackgroundColor() -> UIColor {
        let light = backgroundColorForLightTheme(baseColor: color)
        let dark  = backgroundColorForDarkTheme(baseColor: color)
        return dynamicColor(light: light, dark: dark)
    }

    private func dynamicStandardTextColor() -> UIColor {
        let light = textColorForLightTheme(baseColor: color)
        return dynamicColor(light: light, dark: color)
    }

    private func textColorForLightTheme(baseColor: UIColor) -> UIColor {
        var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        guard baseColor.getHue(&h, saturation: &s, brightness: &b, alpha: &a) else {
            return .label
        }
        return UIColor(hue: h, saturation: s, brightness: b * 0.4, alpha: a)
    }

    private func backgroundColorForLightTheme(baseColor: UIColor) -> UIColor {
        baseColor.withAlphaComponent(0.3)
    }

    private func backgroundColorForDarkTheme(baseColor: UIColor) -> UIColor {
        var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        guard color.getHue(&h, saturation: &s, brightness: &b, alpha: &a) else {
            return baseColor.withAlphaComponent(0.2)
        }
        return UIColor(hue: h, saturation: s, brightness: b * 0.4, alpha: max(0.05, a * 0.7))
    }

    private func dynamicColor(light: UIColor, dark: UIColor) -> UIColor {
        if #available(iOS 13.0, *) {
            return UIColor { traitCollection in
                traitCollection.userInterfaceStyle == .dark ? dark : light
            }
        } else {
            return light
        }
    }
}