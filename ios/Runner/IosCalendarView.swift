import Flutter
import UIKit

class IosCalendarView: NSObject, FlutterPlatformView {
    private var view: UIDatePicker

    init(frame: CGRect, viewId: Int64, args: Any?) {
        view = UIDatePicker()
        view.preferredDatePickerStyle = .inline  
        view.datePickerMode = .date
        super.init()
    }

    func view() -> UIView {
        return view
    }
}

class IosCalendarFactory: NSObject, FlutterPlatformViewFactory {
    func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?) -> FlutterPlatformView {
        return IosCalendarView(frame: frame, viewId: viewId, args: args)
    }
}
