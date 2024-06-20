//
//  ShopifyTests.swift
//  ShopifyTests
//
//  Created by Aser Eid on 02/06/2024.
//

import XCTest
import RxSwift
import RxCocoa

@testable import Shopify

final class NetworkTest: XCTestCase {
    
    var network : NetworkServiceProtocol?
    var disposeBag : DisposeBag!
    
    override func setUp() {
        super.setUp()
        
        network = NetworkService.shared
        disposeBag = DisposeBag()
    }
    
    override func tearDown() {
        super.tearDown()
        
        network = nil
        disposeBag = nil
    }
    
    func testFetchBrands() {
        
        let expectation = expectation(description: "Wait for brands")
        network?.get(url: NetworkConstants.baseURL, endpoint: APIEndpoint.brands.rawValue, parameters: nil, headers: nil).subscribe(onNext: { (data : BrandsResponse) in
            
            XCTAssertEqual(data.smartCollections.count, 12)
            expectation.fulfill()
            
        },onError: { error in
            
            XCTFail("Error occured: \(error.localizedDescription)")
            expectation.fulfill()
            
        }).disposed(by: disposeBag)
        
        waitForExpectations(timeout: 10)
    }
    
    
}
