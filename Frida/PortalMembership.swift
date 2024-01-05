import CTelco

@objc(TelcoPortalMembership)
public class PortalMembership: NSObject, NSCopying {
    public typealias TerminateComplete = (_ result: TerminateResult) -> Void
    public typealias TerminateResult = () throws -> Bool

    private let handle: OpaquePointer

    init(handle: OpaquePointer) {
        self.handle = handle

        super.init()
    }

    public func copy(with zone: NSZone?) -> Any {
        g_object_ref(gpointer(handle))
        return PortalMembership(handle: handle)
    }

    deinit {
        let h = gpointer(handle)
        Runtime.scheduleOnTelcoThread {
            g_object_unref(h)
        }
    }

    public override var description: String {
        return "Telco.PortalMembership()"
    }

    public override func isEqual(_ object: Any?) -> Bool {
        if let membership = object as? PortalMembership {
            return membership.handle == handle
        } else {
            return false
        }
    }

    public override var hash: Int {
        return handle.hashValue
    }

    public func terminate(_ completionHandler: @escaping TerminateComplete = { _ in }) {
        Runtime.scheduleOnTelcoThread {
            telco_portal_membership_terminate(self.handle, nil, { source, result, data in
                let operation = Unmanaged<AsyncOperation<TerminateComplete>>.fromOpaque(data!).takeRetainedValue()

                var rawError: UnsafeMutablePointer<GError>? = nil
                telco_portal_membership_terminate_finish(OpaquePointer(source), result, &rawError)
                if let rawError = rawError {
                    let error = Marshal.takeNativeError(rawError)
                    Runtime.scheduleOnMainThread {
                        operation.completionHandler { throw error }
                    }
                    return
                }

                Runtime.scheduleOnMainThread {
                    operation.completionHandler { true }
                }
            }, Unmanaged.passRetained(AsyncOperation<TerminateComplete>(completionHandler)).toOpaque())
        }
    }
}
