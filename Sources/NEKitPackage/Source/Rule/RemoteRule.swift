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
        checkRemote(session.host) { [weak self] result in
            guard let self else {
                completion(nil)
                return
            }
            
            switch result {
            case .success(let allowed):
                completion(allowed ? adapterFactory : nil)
            case .failure:
                completion(nil)
            }
        }
    }
    
    private func checkRemote(_ domain: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        let url = URL(string: hostURL)!
        let parameters: [String: String] = ["name": domain]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: parameters) else {
            completion(.failure(NSError(domain: "Invalid JSON", code: 0, userInfo: nil)))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
                let error = NSError(domain: "HTTP Error", code: httpResponse.statusCode, userInfo: nil)
                completion(.failure(error))
                return
            }
            
            if let data = data, let response = try? JSONDecoder().decode(RemoteRuleResponse.self, from: data) {
                completion(.success(response.result))
            } else {
                let error = NSError(domain: "Empty response", code: 0, userInfo: nil)
                completion(.failure(error))
            }
        }
        task.resume()
    }
}

private struct RemoteRuleResponse: Decodable {
    let result: Bool
}

