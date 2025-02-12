//
//  RemoteRule.swift
//  NEKitPackage
//
//  Created by Vladislav Simovic on 12.2.25..
//

import Foundation

open class RemoteRule: Rule {
    private let adapterFactory: AdapterFactory
    private let hostURL: String
    
    open override var description: String {
        return "<Remote Rule>"
    }
    
    public init(adapterFactory: AdapterFactory, hostURL: String) {
        self.adapterFactory = adapterFactory
        self.hostURL = hostURL
    }
    
    /**
     Match DNS request to this rule.
     
     - parameter session: The DNS session to match.
     - parameter type:    What kind of information is available.
     
     - returns: The result of match.
     */
    override open func matchDNS(_ session: DNSSession, type: DNSSessionMatchType) -> DNSSessionMatchResult {
        .pass
    }
    
    /**
     Match connect session to this rule.
     
     - parameter session: connect session to match.
     
     - returns: The configured adapter if matched, return `nil` if not matched.
     */
    override open func match(_ session: ConnectSession, completion: @escaping (AdapterFactory?) -> Void) {
        checkDomain(session.host) { [unowned self] result in
            switch result {
            case .success(let allowed):
                completion(allowed ? adapterFactory : nil)
            case .failure:
                completion(nil)
            }
        }
    }
    
    private func checkDomain(_ domain: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        Task {
            let result = await checkRemote(domain)
            completion(result)
        }
    }
    
    private func checkRemote(_ domain: String) async -> Result<Bool, Error> {
        let url = URL(string: hostURL)!
        let parameters: [String: String] = ["domain": domain]

        guard let jsonData = try? JSONSerialization.data(withJSONObject: parameters) else {
            return .failure(NSError(domain: "Invalid JSON", code: 0, userInfo: nil))
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
                return .failure(NSError(domain: "HTTP Error", code: httpResponse.statusCode, userInfo: nil))
            }
            
            let decodedResponse = try JSONDecoder().decode(APIResponse.self, from: data)
            return .success(decodedResponse.result)
        } catch {
            return .failure(error)
        }
    }
}

private struct APIResponse: Decodable {
    let result: Bool
}

