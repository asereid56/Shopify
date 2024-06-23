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
    
    func testPost() {
            let expectation = expectation(description: "wait to create draft order")
            let linItems = LineItem(title: "DummyProduct", price: "0.0", quantity: 1)
            let draftOrder = DraftOrder(lineItems: [linItems])
            let draftOrderWrapper = DraftOrderWrapper(draftOrder: draftOrder)
            let endPoint = APIEndpoint.createDraftOrder.rawValue

            network?.post(url: NetworkConstants.baseURL, endpoint: endPoint, body: draftOrderWrapper, headers: nil, responseType: DraftOrderWrapper.self)
                .subscribe(onNext: { success , msg , response in

                    XCTAssertTrue(success)
                    XCTAssertEqual(response?.draftOrder?.lineItems?.count, 1)
                    XCTAssertEqual(response?.draftOrder?.lineItems?.first?.title , "DummyProduct")
                    expectation.fulfill()

                },onError: { error in

                    XCTFail("Error occurred: (error.localizedDescription)")
                    expectation.fulfill()

                }).disposed(by: disposeBag)

            waitForExpectations(timeout: 10)
        }
    
}
