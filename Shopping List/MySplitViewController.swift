//
//  MySplitViewController.swift
//  Shopping List
//
//  Created by Mirza Irwan on 2/7/17.
//  Copyright © 2017 Mirza Irwan <mirza.irwan.osman@gmail.com>. All rights reserved.
//

import UIKit

class MySplitViewController: UISplitViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        print("\(#function) - \(type(of: self))")
        self.delegate = self
        // Do any additional setup after loading the view.
    }
}

extension MySplitViewController: UISplitViewControllerDelegate {
    
    //Collapsing and Expanding the interface
    
//    func primaryViewController(forCollapsing splitViewController: UISplitViewController) -> UIViewController? {
//        print("\(#function) - \(type(of: self))")
//        return nil
//    }
    
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        
        print("\(#function) - \(type(of: self))")
        return true
    }
    
//    func primaryViewController(forExpanding splitViewController: UISplitViewController) -> UIViewController? {
//        print("\(#function) - \(type(of: self))")
//        return nil
//    }
//    
//    func splitViewController(_ splitViewController: UISplitViewController, separateSecondaryFrom primaryViewController: UIViewController) -> UIViewController? {
//        print("\(#function) - \(type(of: self))")
//        return nil
//    }
    
    //Overriding the Presentation Behavior
    
//    func splitViewController(_ splitViewController: UISplitViewController, show vc: UIViewController, sender: Any?) -> Bool {
//        print("\(#function) - \(type(of: self))")
//        return false
//    }
//    
//    func splitViewController(_ splitViewController: UISplitViewController, showDetail vc: UIViewController, sender: Any?) -> Bool {
//        print("\(#function) - \(type(of: self))")
//        return false
//    }
    
}
