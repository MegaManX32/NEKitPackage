import Foundation
import CocoaLumberjackSwift

open class DebugObserverFactory: ObserverFactory {
    public override init() {}

//    override open func getObserverForTunnel(_ tunnel: Tunnel) -> Observer<TunnelEvent>? {
//        return DebugTunnelObserver()
//    }
//
//    override open func getObserverForProxyServer(_ server: ProxyServer) -> Observer<ProxyServerEvent>? {
//        return DebugProxyServerObserver()
//    }
//
//    override open func getObserverForProxySocket(_ socket: ProxySocket) -> Observer<ProxySocketEvent>? {
//        return DebugProxySocketObserver()
//    }
//
//    override open func getObserverForAdapterSocket(_ socket: AdapterSocket) -> Observer<AdapterSocketEvent>? {
//        return DebugAdapterSocketObserver()
//    }

    open override func getObserverForRuleManager(_ manager: RuleManager) -> Observer<RuleMatchEvent>? {
        return DebugRuleManagerObserver()
    }
}

open class DebugTunnelObserver: Observer<TunnelEvent> {
    override open func signal(_ event: TunnelEvent) {
        switch event {
        case .receivedRequest,
             .closed:
//            Log("\(event)")
            DDLogInfo("\(event)")
        case .opened,
             .connectedToRemote,
             .updatingAdapterSocket:
//            Log("\(event)")
            DDLogVerbose("\(event)")
        case .closeCalled,
             .forceCloseCalled,
             .receivedReadySignal,
             .proxySocketReadData,
             .proxySocketWroteData,
             .adapterSocketReadData,
             .adapterSocketWroteData:
//            Log("\(event)")
            DDLogDebug("\(event)")
        }
    }
}

open class DebugProxySocketObserver: Observer<ProxySocketEvent> {
    override open func signal(_ event: ProxySocketEvent) {
        switch event {
        case .errorOccured:
//            Log("\(event)")
            DDLogError("\(event)")
        case .disconnected,
             .receivedRequest:
//            Log("\(event)")
            DDLogInfo("\(event)")
        case .socketOpened,
             .askedToResponseTo,
             .readyForForward:
//            Log("\(event)")
            DDLogVerbose("\(event)")
        case .disconnectCalled,
             .forceDisconnectCalled,
             .readData,
             .wroteData:
//            Log("\(event)")
            DDLogDebug("\(event)")
        }
    }
}

open class DebugAdapterSocketObserver: Observer<AdapterSocketEvent> {
    override open func signal(_ event: AdapterSocketEvent) {
        switch event {
        case .errorOccured:
//            Log("\(event)")
            DDLogError("\(event)")
        case .disconnected,
             .connected:
//            Log("\(event)")
            DDLogInfo("\(event)")
        case .socketOpened,
             .readyForForward:
//            Log("\(event)")
            DDLogVerbose("\(event)")
        case .disconnectCalled,
             .forceDisconnectCalled,
             .readData,
             .wroteData:
//            Log("\(event)")
            DDLogDebug("\(event)")
        }
    }
}

open class DebugProxyServerObserver: Observer<ProxyServerEvent> {
    override open func signal(_ event: ProxyServerEvent) {
        switch event {
        case .started,
             .stopped:
//            Log("\(event)")
            DDLogInfo("\(event)")
        case .newSocketAccepted,
             .tunnelClosed:
//            Log("\(event)")
            DDLogVerbose("\(event)")
        }
    }
}

open class DebugRuleManagerObserver: Observer<RuleMatchEvent> {
    open override func signal(_ event: RuleMatchEvent) {
        switch event {
        case .ruleDidNotMatch, .dnsRuleMatched:
//            Log("\(event)")
            DDLogVerbose("\(event)")
        case .ruleMatched:
//            Log("\(event)")
            DDLogInfo("\(event)")
        }
    }
}
