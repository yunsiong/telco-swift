import CTelco

@objc(TelcoApplicationDetails)
public class ApplicationDetails: NSObject, NSCopying {
    private let handle: OpaquePointer

    init(handle: OpaquePointer) {
        self.handle = handle
    }

    public func copy(with zone: NSZone?) -> Any {
        g_object_ref(gpointer(handle))
        return ApplicationDetails(handle: handle)
    }

    deinit {
        g_object_unref(gpointer(handle))
    }

    public var identifier: String {
        return String(cString: telco_application_get_identifier(handle))
    }

    public var name: String {
        return String(cString: telco_application_get_name(handle))
    }

    public var pid: UInt? {
        let value = telco_application_get_pid(handle)
        return value != 0 ? UInt(value) : nil
    }

    public lazy var parameters: [String: Any] = {
        var result = Marshal.dictionaryFromParametersDict(telco_application_get_parameters(handle))

        if let started = result["started"] as? String {
            result["started"] = Marshal.dateFromISO8601(started) ?? NSNull()
        }

        return result
    }()

    public lazy var icons: [NSImage] = {
        guard let icons = parameters["icons"] as? [[String: Any]] else {
            return []
        }
        return icons.compactMap(Marshal.iconFromVarDict)
    }()

    public override var description: String {
        if let pid = self.pid {
            return "Telco.ApplicationDetails(identifier: \"\(identifier)\", name: \"\(name)\", pid: \(pid), parameters: \(parameters))"
        } else {
            return "Telco.ApplicationDetails(identifier: \"\(identifier)\", name: \"\(name)\", parameters: \(parameters))"
        }
    }

    public override func isEqual(_ object: Any?) -> Bool {
        if let details = object as? ApplicationDetails {
            return details.handle == handle
        } else {
            return false
        }
    }

    public override var hash: Int {
        return handle.hashValue
    }
}
