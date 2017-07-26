//
//  ExchangeRateWebApi.swift
//  Shopping List
//
//  Created by Mirza Irwan on 26/7/17.
//  Copyright © 2017 Mirza Irwan <mirza.irwan.osman@gmail.com>. All rights reserved.
//

import Foundation

class ExchangeRateWebApi {
    
    private let stringUrl = "http://api.fixer.io" //http://api.fixer.io/latest?base=USD
    
    private var components = URLComponents()
    
    /* Parse the data into usable form */
    private var parsedExchangeRateInJson: [String: Double]?
    
    init(scheme: String, host: String, path: String) {
        components.scheme = scheme
        components.host = host
        components.path = path
        components.queryItems = [URLQueryItem]()
    }
    
    func getWebApiUrl(paramName: String, baseCurrencyCode paramValue: String) -> URL? {
        
        let queryItem = URLQueryItem(name: paramName, value: paramValue)
        components.queryItems?.append(queryItem)
        return components.url
    }
    
    public func getExchangeRates(paramName: String, baseCurrencyCode paramValue: String, completionHandlerForMain: @escaping (Dictionary<String, Double>?) -> Void) {
        
        guard let webApiUrl = getWebApiUrl(paramName: paramName, baseCurrencyCode: paramValue) else { return }
        
        //Create session
        let task = URLSession.shared.dataTask(with: webApiUrl, completionHandler: { data, response, error in
            
            self.populateExchangeRateTable(data: data, response: response, error: error)
        
            //let exchangeRate = self.filter(for: targetCurrencyCode)
            //print(">>>Rate \(exchangeRate.costInForeignCurrencyToGetOneUnitOfBaseCurrency!)")
            print(">>>Rates \(String(describing: self.parsedExchangeRateInJson))")
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
            
            print(">>>parsedExchangeRateInJson \(parsedExchangeRateInJson)")
        } catch  {
            print("Error")
        }
    }
}
