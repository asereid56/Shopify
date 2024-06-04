//
//  NetworkService.swift
//  Shopify
//
//  Created by Apple on 04/06/2024.
//

import Foundation
import RxSwift
import RxAlamofire
import Alamofire

enum APIEndpoint: String {
    case postUserAddress = "/api/user/address"
    case createCustomer  = "/customers.json"
    case address = "/customers/{customer_id}/addresses.json"
}

// Define a protocol for NetworkService
protocol NetworkServiceProtocol {
    func request<T: Decodable>(url : String , endpoint: String, method: HTTPMethod, parameters: [String: Any]?, headers: HTTPHeaders?) -> Observable<T>
    func post<T: Codable>(url : String ,endpoint: String, body: T, headers: HTTPHeaders?) -> Observable<(HTTPURLResponse, Data)>
}

class NetworkService: NetworkServiceProtocol {
    private let disposeBag = DisposeBag()

    // Helper function to create full URL and default headers
    private func createRequestDetails(url : String ,endpoint: String, headers: HTTPHeaders?) -> (String, HTTPHeaders) {
        let url = "\(NetworkConstants.baseURL)\(endpoint)"
        var combinedHeaders = headers ?? HTTPHeaders()
        combinedHeaders.add(name: "Authorization", value: NetworkConstants.apiKey)
        return (url, combinedHeaders)
    }

    // Generic function to make network requests
    func request<T: Decodable>(url : String ,endpoint: String, method: HTTPMethod = .get, parameters: [String: Any]? = nil, headers: HTTPHeaders? = nil) -> Observable<T> {
        let (url, combinedHeaders) = createRequestDetails(url : url ,endpoint: endpoint, headers: headers)

        return RxAlamofire
            .requestData(method, url, parameters: parameters, encoding: URLEncoding.default, headers: combinedHeaders)
            .flatMap { response, data -> Observable<T> in
                do {
                    let decodedObject = try JSONDecoder().decode(T.self, from: data)
                    return Observable.just(decodedObject)
                } catch {
                    return Observable.error(error)
                }
            }
    }

    // Generic function to post data
    func post<T: Codable>(url: String, endpoint: String, body: T, headers: HTTPHeaders? = nil) ->Observable<(HTTPURLResponse, Data)>  {
        let (completeURL, combinedHeaders) = createRequestDetails(url: url, endpoint: endpoint, headers: headers)
        
        do {
            let jsonData = try JSONEncoder().encode(body)
            return Observable.create { observer in
                var request = URLRequest(url: URL(string: completeURL)!)
                request.httpMethod = HTTPMethod.post.rawValue
                request.headers = combinedHeaders
                request.httpBody = jsonData
                
                let disposable = RxAlamofire.request(request)
                    .responseData()
                    .subscribe(onNext: { (response, data) in
                        observer.onNext((response , data))
                        observer.onCompleted()
                    }, onError: { error in
                        observer.onError(error)
                    })
                
                return Disposables.create {
                    disposable.dispose()
                }
            }
        } catch {
            return Observable.error(error)
        }
    }
}


class Address: Codable {
    var id: Int?
    var customerId: Int?
    var firstName: String?
    var lastName: String?
    var company: String?
    var address1: String?
    var address2: String?
    var city: String?
    var province: String?
    var country: String?
    var zip: String?
    var phone: String?
    var name: String?
    var provinceCode: String?
    var countryCode: String?
    var countryName: String?
    var `default`: Bool?

    enum CodingKeys: String, CodingKey {
        case id
        case customerId = "customer_id"
        case firstName = "first_name"
        case lastName = "last_name"
        case company
        case address1
        case address2
        case city
        case province
        case country
        case zip
        case phone
        case name
        case provinceCode = "province_code"
        case countryCode = "country_code"
        case countryName = "country_name"
        case `default`
    }
}

class AddressList: Codable {
    var addresses: [Address]?

    enum CodingKeys: String, CodingKey {
        case addresses = "addresses"
    }
}

struct Customer: Codable {
    let customer: CustomerDetails
}

struct CustomerDetails: Codable {
    let firstName: String
    let lastName: String
    let email: String
    // Add other customer attributes as needed
}
