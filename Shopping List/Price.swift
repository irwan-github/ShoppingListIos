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
    
    var valueConvert: Int {
        get {
            return Int(value)
        }
        set {
            value = Int32(newValue)
        }
    }
    
    var quantityConvert: Int {
        set {
            quantity = Int32(newValue)
        }
        get {
            return Int(quantity)
        }
    }
    
    class func filter(prices: [Price], match: PriceType) -> Price? {
        let priceTypeFilter: NSPredicate
        
        switch match {
        case .unit:
            priceTypeFilter = NSPredicate(format: "quantity == 1")
        case .bundle:
            priceTypeFilter = NSPredicate(format: "quantity >= 2")
            
        }
        
        if prices.count > 0 {
            let nsprices = prices as NSArray
            
            let priceRes = nsprices.filtered(using: priceTypeFilter)
            if priceRes.count > 0 {
                return priceRes[0] as? Price
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
    
    class func findPrices(of item: Item, moc: NSManagedObjectContext) throws -> [Price]? {
        
        //Create request
        let fetchRequest: NSFetchRequest<Price> = Price.fetchRequest()
        
        //Filter by
        let filter = NSPredicate(format: "item = %@", item)
        fetchRequest.predicate = filter
        
        //Sort by
        let sortBy = [NSSortDescriptor(key: "quantity", ascending: true)]
        fetchRequest.sortDescriptors = sortBy
        
        //Go fetch
        return try? moc.fetch(fetchRequest)
        
    }
}
