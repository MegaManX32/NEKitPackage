import Foundation

/// The class managing rules.
open class RuleManager {
    /// The current used `RuleManager`, there is only one manager should be used at a time.
    ///
    /// - note: This should be set before any DNS or connect sessions.
    public static var currentManager: RuleManager = RuleManager(fromRules: [], appendDirect: true)

    /// The rule list.
    var rules: [Rule] = []

    open var observer: Observer<RuleMatchEvent>?

    /**
     Create a new `RuleManager` from the given rules.

     - parameter rules:        The rules.
     - parameter appendDirect: Whether to append a `DirectRule` at the end of the list so any request does not match with any rule go directly.
     */
    public init(fromRules rules: [Rule], appendDirect: Bool = false) {
        self.rules = rules

        if appendDirect || self.rules.count == 0 {
            self.rules.append(DirectRule())
        }

        observer = ObserverFactory.currentFactory?.getObserverForRuleManager(self)
    }

    /**
     Match DNS request to all rules.

     - parameter session: The DNS session to match.
     - parameter type:    What kind of information is available.
     */
    func matchDNS(_ session: DNSSession, type: DNSSessionMatchType) {
        for (i, rule) in rules[session.indexToMatch..<rules.count].enumerated() {
            let result = rule.matchDNS(session, type: type)

            observer?.signal(.dnsRuleMatched(session, rule: rule, type: type, result: result))

            switch result {
            case .fake, .real, .unknown:
                session.matchedRule = rule
                session.matchResult = result
                session.indexToMatch = i + session.indexToMatch // add the offset
                return
            case .pass:
                break
            }
        }
    }

    /**
     Match connect session to all rules.

     - parameter session: connect session to match.

     - returns: The matched configured adapter.
     */
    func match(_ session: ConnectSession, queue: DispatchQueue, completion: @escaping (AdapterFactory?) -> Void) {
        if session.matchedRule != nil {
            observer?.signal(.ruleMatched(session, rule: session.matchedRule!))
            session.matchedRule!.match(session) { adapterFactory in
                queue.async {
                    completion(adapterFactory)
                }
            }
            return
        }
        
        iterateRules(iterator: rules.makeIterator(), session: session, queue: queue, completion: completion)
    }
    
    private func iterateRules(iterator: IndexingIterator<[Rule]>,
                              session: ConnectSession,
                              queue: DispatchQueue,
                              completion: @escaping (AdapterFactory?) -> Void) {
        var iterator = iterator
        guard let rule = iterator.next() else {
            completion(nil)
            return
        }
        
        rule.match(session) { adapterFactory in
            queue.async { [weak self] in
                guard let self else {
                    completion(nil)
                    return
                }
                
                if let adapterFactory {
                    observer?.signal(.ruleMatched(session, rule: rule))
                    session.matchedRule = rule
                    completion(adapterFactory)
                } else {
                    observer?.signal(.ruleDidNotMatch(session, rule: rule))
                    iterateRules(iterator: iterator, session: session, queue: queue, completion: completion)
                }
            }
        }
    }
}
