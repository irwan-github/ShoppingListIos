//
//  Price.swift
//  Shopping List
//
//  Created by Mirza Irwan on 1/7/17.
//  Copyright © 2017 Mirza Irwan <mirza.irwan.osman@gmail.com>. All rights reserved.
//

import UIKit
import CoreData

class Price: NSManagedObject {
    
    /**
     The value of price. Convert Int32 to Int and vice-versa. Conveient to work with Int type in view controllers
     */
    var valueConvert: Int {
        get {
            return Int(value)
        }
        set {
            value = Int32(newValue)
        }
    }
    
    /**
     Convert Int32 to Int and vice-versa. Conveient to work with Int type in view controllers
     */
    var quantityConvert: Int {
        set {
            quantity = Int32(newValue)
        }
        get {
            return Int(quantity)
        }
    }
    
    var currencySymbol: String! {
        
        if let firstIndex = currencyCode?.startIndex, let targetIndex = currencyCode?.index(firstIndex, offsetBy: 1) {
            guard let countryCode = currencyCode?[firstIndex...targetIndex] else { return currencyCode }
            let theLocale = Locale(identifier: "en_" + countryCode)
            let formatter = NumberFormatter()
            formatter.locale = theLocale
            formatter.currencyCode = currencyCode
            return formatter.currencySymbol
            
        } else {
            return currencyCode
        }

    }
    
    /**
     By definition, unit price is price of one unit.
     By definition, bundle price is price of more than 1 unit
     */
    class func filterSet(of prices: NSSet, match: PriceType) -> Price? {
        let priceTypeFilter: NSPredicate
        
        switch match {
        case .unit:
            priceTypeFilter = NSPredicate(format: "quantity == 1")
        case .bundle:
            priceTypeFilter = NSPredicate(format: "quantity > 1")
        }
        
        let priceRes = prices.filtered(using: priceTypeFilter)
        return priceRes.first as? Price
    }
    
    class func findPrices(of item: Item, in managedObjectContext: NSManagedObjectContext) throws -> [Price]? {
        
        //Create request
        let fetchRequest: NSFetchRequest<Price> = Price.fetchRequest()
        
        //Filter by
        let filter = NSPredicate(format: "item = %@", item)
        fetchRequest.predicate = filter
        
        //Sort by
        let sortBy = [NSSortDescriptor(key: "quantity", ascending: true)]
        fetchRequest.sortDescriptors = sortBy
        
        //Go fetch
        return try? managedObjectContext.fetch(fetchRequest)
        
    }
}
