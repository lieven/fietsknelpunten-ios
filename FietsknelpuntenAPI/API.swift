//
//  API.swift
//  Fietsknelpunten
//
//  Created by Lieven Dekeyser on 12/11/16.
//  Copyright © 2016 Fietsknelpunten. All rights reserved.
//

import UIKit

@objc public enum ClientError: Int, Error
{
	case invalidRequest = 1
	case noResponse
	case parseError
}

public class ServerError: NSError
{
	static let domain = "Fietsknelpunten.API.ServerErrorDomain"
	
	convenience init(code: Int, userInfo: [String: Any]?)
	{
		self.init(domain: ServerError.domain, code: code, userInfo: userInfo)
	}
}

public class HttpStatusCode: NSError
{
	public static let domain = "Fietsknelpunten.API.HttpStatusCodeErrorDomain"
	
	public init(code: Int)
	{
		super.init(domain: HttpStatusCode.domain, code: code, userInfo: nil)
	}
	
	public required init?(coder aDecoder: NSCoder)
	{
		fatalError("init(coder:) has not been implemented")
	}
}


internal class API: NSObject
{
	public static var shared: API? = {
		
		guard let infoDict = Bundle.main.infoDictionary else
		{
			return nil
		}
		
		guard let baseURLString = infoDict["FietsknelpuntenBaseURL"] as? String, let baseURL = URL(string: baseURLString) else
		{
			return nil
		}
		
		guard let appID = infoDict["FietsknelpuntenAppID"] as? String else
		{
			return nil
		}
		
		return API(baseURL: baseURL, appID: appID)
		
	}()
	
	private let baseURL: URL
	private let appID: String
	
	
	internal init(baseURL: URL, appID: String)
	{
		self.baseURL = baseURL
		self.appID = appID
	}
	
	public func sendRequest(action: String, arguments: [String:String]?, completion: @escaping (Bool, Any?, Error?)->())
	{
		guard let request = request(with: action, arguments: arguments) else
		{
			completion(false, nil, ClientError.invalidRequest)
			return
		}
		
		let task = URLSession.shared.dataTask(with: request)
		{
			(data, response, error) in
			
			if let error = error
			{
				completion(false, nil, error)
			}
			else if let httpResponse = response as? HTTPURLResponse, let data = data
			{
				let statusCode = httpResponse.statusCode
				
				if statusCode < 200 || statusCode >= 300
				{
					completion(false, nil, HttpStatusCode(code: statusCode))
				}
				else
				{
					do
					{
						let parsedResponse = try JSONSerialization.jsonObject(with: data, options: [])
						
						if let responseDict = parsedResponse as? [String: Any], let errorCode = responseDict["error"] as? Int
						{
							completion(false, responseDict, ServerError(code: errorCode, userInfo: responseDict))
						}
						else
						{
							completion(true, parsedResponse, nil)
						}
					}
					catch (_)
					{
						completion(false, nil, ClientError.parseError)
						return
					}
				}
			}
			else
			{
				completion(false, nil, ClientError.noResponse)
			}
		}
		
		task.resume()
	}
	
	internal func request(with action: String, arguments: [String:String]?) -> URLRequest?
	{
		guard var components = URLComponents(url: self.baseURL, resolvingAgainstBaseURL: true) else
		{
			return nil
		}
		
		var queryItems = [
			URLQueryItem(name: "module", value: "api"),
			URLQueryItem(name: "action", value: action)
		]
		
		if let arguments = arguments
		{
			for (argument, value) in arguments
			{
				queryItems.append(URLQueryItem(name: argument, value: value))
			}
		}
		
		components.queryItems = queryItems
		
		guard let url = components.url else
		{
			return nil
		}
		
		var result = URLRequest(url: url)
		result.setValue(self.appID, forHTTPHeaderField: "X_FIETSKNELPUNTEN_APPID")
		
		return result
	}
}
