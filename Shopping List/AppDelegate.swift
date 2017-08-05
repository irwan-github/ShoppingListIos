//
//  AppDelegate.swift
//  Shopping List
//
//  Created by Mirza Irwan on 1/7/17.
//  Copyright © 2017 Mirza Irwan <mirza.irwan.osman@gmail.com>. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        let splitViewController = window!.rootViewController as! UISplitViewController
        
        //Assign app delegate as split view delegate
        splitViewController.delegate = self
        
        splitViewController.preferredDisplayMode = .allVisible
        
        registerDefaultsFromSettingsBundle()
        
        return true
    }
    
    private func setDefaultCountryCode() {
        let appDefaults = UserDefaults.standard
        let currentLocale = Locale.current
        let defaultCountryCode = currentLocale.regionCode ?? "US"
        appDefaults.set(defaultCountryCode, forKey: "country_code")
    }
    
    private func registerDefaultsFromSettingsBundle() {
        
        //Get the user defaults object
        let appDefaults = UserDefaults.standard
        
        //Check if country code is valid in app defaults
        if let countryCodeDef = appDefaults.value(forKey: "country_code") as? String {
            
            if countryCodeDef.isEmpty ||  !CurrencyHelper.isValidCountry(code: countryCodeDef) {
                setDefaultCountryCode()
            }
        } else {

            setDefaultCountryCode()
        }
        
        //Dictionary to hold the settings bundle default
        var settingsBundleDefaults = [String: Any]()
        
        //Get the url of the root plist
        guard let settingsUrl = Bundle.main.url(forResource: "Root", withExtension: "plist",
                                                subdirectory: "Settings.bundle") else { return }
        
        let settingsPath = settingsUrl.path
        
        //Read the plist into memory
        guard let data = FileManager.default.contents(atPath: settingsPath) else { return }
        
        do {
            //Convert the plist to a Dictionary
            guard let settingsDict = (try PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [String: AnyObject]) else { return }
            
            //Get the preference items as an Array
            guard let prefs = settingsDict["PreferenceSpecifiers"] as? [[String: AnyObject]] else { return }
            
            //Iterate over the array
            for aPref in prefs {
                
                if let key = aPref["Key"] as? String, let value = aPref["DefaultValue"] {
                    print("Key is \(key) , Value is \(value)")
                    
                    settingsBundleDefaults[key] = value
                }
            }
            
            //Register the default values into UserDefaults
            appDefaults.register(defaults: settingsBundleDefaults)
            appDefaults.synchronize()
            
        } catch {
            let nserror = error as NSError
            print("Error occured \(nserror)", nserror.userInfo)
            
        }
        
        
    }
    

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        saveContext()
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }
    
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "Shopping_List")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    //For convenience
    static var persistentContainer: NSPersistentContainer {
        return (UIApplication.shared.delegate as! AppDelegate).persistentContainer
    }
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    // MARK: - For testing only
    func loadDummyShoppingList() {
        
        let groceryShoppingList = ShoppingList.findOrCreateNew(name: "Grocery", context: persistentContainer.viewContext)
        if (groceryShoppingList?.objectID.isTemporaryID)! {
            //New shopping liat
            groceryShoppingList?.name = "Grocery"
            groceryShoppingList?.comments = "Everyday stuffs"
            groceryShoppingList?.lastUpdatedOn = NSDate()
        }
        
        let artShoppingList = ShoppingList.findOrCreateNew(name: "Art project", context: persistentContainer.viewContext)
        if (artShoppingList?.objectID.isTemporaryID)! {
            //New shopping liat
            artShoppingList?.name = "Art project"
            artShoppingList?.comments = "For NAFA"
            artShoppingList?.lastUpdatedOn = NSDate()
        }
        
        saveContext()
        
    }
    
    // MARK: - Collapsing and Expanding the interface
    
    /**
     Called by iPhone 7+ Potrait, iPhone 7 (Potrait & Landscape), iPhone6, iPhone SE because splitViewController.preferredDisplayMode = .allVisible
     */
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController:UIViewController, onto primaryViewController:UIViewController) -> Bool {
        
        //I do not want the screen "Landing secondary view controller" to be the first screen in iPhone because it is contains no data.
        //Return true to indicate that we have handled the collapse by doing nothing; the secondary controller will be discarded.
        if let title = secondaryViewController.title, title == "Landing secondary view controller" {
            return true
        }
        
        return false
    }
    
    // MARK: - Responding to display mode changes
    
    /**
     At appropriate times, the split view controller calls this method to determine which display mode to apply to itself in response to user-initiated actions.
     
     Appropriate times:
     1. From iPhone 7+ potrait to landscape
     iPad starting the app
     iPhone 7+ starting in landscape
     On tapping the splitViewController.displayModeButtonItem
     */
    func targetDisplayModeForAction(in svc: UISplitViewController) -> UISplitViewControllerDisplayMode {
        print(">>> \(#function) - Display mode = \(svc.displayMode.rawValue)")
        return .automatic
    }
    
    // MARK: - Overriding the presentation behaviour
    
    func splitViewController(_ splitViewController: UISplitViewController, show vc: UIViewController, sender: Any?) -> Bool {
        print(">>> \(#function)")
        return false
    }
    
}

