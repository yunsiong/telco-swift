import CTelco

@objc(TelcoCrashDetails)
public class CrashDetails: NSObject, NSCopying {
    private let handle: OpaquePointer

    init(handle: OpaquePointer) {
        self.handle = handle
    }

    public func copy(with zone: NSZone?) -> Any {
        g_object_ref(gpointer(handle))
        return CrashDetails(handle: handle)
    }

    deinit {
        g_object_unref(gpointer(handle))
    }

    public var pid: UInt {
        return UInt(telco_crash_get_pid(handle))
    }

    public var processName: String {
        return String(cString: telco_crash_get_process_name(handle))
    }

    public var summary: String {
        return String(cString: telco_crash_get_summary(handle))
    }

    public var report: String {
        return String(cString: telco_crash_get_report(handle))
    }

    public lazy var parameters: [String: Any] = {
        return Marshal.dictionaryFromParametersDict(telco_crash_get_parameters(handle))
    }()

    public override var description: String {
        return "Telco.CrashDetails(pid: \(pid), processName: \"\(processName)\", summary: \"\(summary)\")"
    }

    public override func isEqual(_ object: Any?) -> Bool {
        if let details = object as? CrashDetails {
            return details.handle == handle
        } else {
            return false
        }
    }

    public override var hash: Int {
        return handle.hashValue
    }
}
