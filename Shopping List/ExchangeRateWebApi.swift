//
//  ExchangeRateWebApi.swift
//  Shopping List
//
//  Created by Mirza Irwan on 26/7/17.
//  Copyright © 2017 Mirza Irwan <mirza.irwan.osman@gmail.com>. All rights reserved.
//

import Foundation

class ExchangeRateWebApi {
    
    private var urlComponents: URLComponents?
    
    /* Parse the data into usable form */
    private var parsedExchangeRateInJson: [String: Double]?
    
    init(scheme: String, host: String, path: String) {
        urlComponents = URLComponents()
        urlComponents?.scheme = scheme
        urlComponents?.host = host
        urlComponents?.path = path
        
    }
    
    init() {
        let stringUrl = UserDefaults.standard.value(forKey: "exchange_rate_web_api") as! String
        urlComponents = URLComponents(string: stringUrl)
    }
    
    func getWebApiUrl(paramName: String, baseCurrencyCode paramValue: String) -> URL? {
        
        let queryItem = URLQueryItem(name: paramName, value: paramValue)
        
        if urlComponents?.queryItems == nil {
            urlComponents?.queryItems = [URLQueryItem]()
        }
        
        urlComponents?.queryItems?.append(queryItem)
        let url = urlComponents?.url
        return url
    }
    
    public func getExchangeRates(paramName: String, baseCurrencyCode paramValue: String, completionHandlerForMain: @escaping (Dictionary<String, Double>?) -> Void) {
        
        guard let webApiUrl = getWebApiUrl(paramName: paramName, baseCurrencyCode: paramValue) else { return }
        
        //Create session
        let task = URLSession.shared.dataTask(with: webApiUrl, completionHandler: { data, response, error in
            
            self.populateExchangeRateTable(data: data, response: response, error: error)
            
            DispatchQueue.main.sync {
                completionHandlerForMain(self.parsedExchangeRateInJson)
            }
        })
        
        task.resume()
        
    }
    
    /**
     Retrieves the exchange rate table from the web based on country code in Settings App
    */
    public func getExchangeRates(completionHandlerForMain: @escaping (Dictionary<String, Double>?) -> Void) {
        
        let currencyHelper = CurrencyHelper()
        let currencyCode = currencyHelper.getHomeCurrencyCode() ?? Locale.current.currencyCode!
        guard let webApiUrl = getWebApiUrl(paramName: "base", baseCurrencyCode: currencyCode) else { return }
        
        //Create session
        let task = URLSession.shared.dataTask(with: webApiUrl, completionHandler: { data, response, error in
            
            self.populateExchangeRateTable(data: data, response: response, error: error)
            
            DispatchQueue.main.sync {
                completionHandlerForMain(self.parsedExchangeRateInJson)
            }
        })
        
        task.resume()
        
    }
    
    /**
     For completion handler
     */
    func populateExchangeRateTable(data: Data?, response: URLResponse?, error: Error?) {
        
        if error != nil {
            return
        }
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode >= 200 && httpResponse.statusCode < 300 else { return }
        
        guard let rawJsonData = data else { return }
        
        self.parseExchangeRates(rawJsonData: rawJsonData)
        
    }
    
    private func parseExchangeRates(rawJsonData data: Data) {
        
        do {
            guard let parsedData = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: AnyObject] else {
                return
            }
            
            parsedExchangeRateInJson = parsedData["rates"] as? [String: Double]
            
        } catch  {
            print("Error")
        }
    }
}
