//
//  APITests.swift
//  Fietsknelpunten
//
//  Created by Lieven Dekeyser on 12/11/16.
//  Copyright © 2016 Fietsknelpunten. All rights reserved.
//

import XCTest
@testable import FietsknelpuntenAPI


class APITests: XCTestCase {
    
	static let baseURLString = "http://localhost"
	static let appID = "appID"
	
	let api = API(baseURL: URL(string: baseURLString)!, appID: appID)
	
	func testRequest()
	{
		let action = "action"
		let argumentName = "argument"
		let argumentValue = "value"
		
		let urlRequest = api.request(with: action, arguments: [argumentName: argumentValue])
		XCTAssertNotNil(urlRequest)
		
		guard let requestURL = urlRequest?.url, let components = URLComponents(url: requestURL, resolvingAgainstBaseURL: true), let queryItems = components.queryItems else
		{
			XCTFail()
			return
		}
	
		var queryItemDict = [String: String]()
		
		for queryItem in queryItems
		{
			if let _ = queryItemDict[queryItem.name]
			{
				XCTFail("Query item should only occur once")
			}
			else if let value = queryItem.value
			{
				queryItemDict[queryItem.name] = value
			}
			else
			{
				XCTFail("Query item should have a value")
			}
		}
		
		XCTAssertEqual(queryItemDict, ["module": "api", "action": action, argumentName: argumentValue])
		
		if let headerFields = urlRequest?.allHTTPHeaderFields
		{
			XCTAssertEqual(headerFields, ["X_FIETSKNELPUNTEN_APPID": APITests.appID])
		}
		else
		{
			XCTFail("App ID should be set")
		}
	}
}
