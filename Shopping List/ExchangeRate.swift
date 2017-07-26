//
//  ExchangeRate.swift
//  Shopping List
//
//  Created by Mirza Irwan on 26/7/17.
//  Copyright © 2017 Mirza Irwan <mirza.irwan.osman@gmail.com>. All rights reserved.
//

import Foundation

struct ExchangeRate {
    
    let foreignCurrencyCode: String?
    let costInForeignCurrencyToGetOneUnitOfBaseCurrency: Double?
    let currencyHelper: CurrencyHelper = CurrencyHelper()
    
    func convert(foreignAmount: Double) -> String? {
        
        if costInForeignCurrencyToGetOneUnitOfBaseCurrency == nil {
            return nil
        }
        
        let formatter: NumberFormatter = NumberFormatter()
        
        formatter.locale = currencyHelper.userLocale
        
        formatter.numberStyle = .currency
        
        formatter.internationalCurrencySymbol = currencyHelper.getHomeCurrencyCode()
        
        let translated = foreignAmount / (costInForeignCurrencyToGetOneUnitOfBaseCurrency!)
        
        let translatedNumber = NSNumber(value: translated)
        
        let stringNumber = formatter.string(from: translatedNumber)
        
        return stringNumber
    }
}
