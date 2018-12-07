//
//  UsageViewController.swift
//  Wally
//
//  Created by Petrick on 07/12/18.
//  Copyright © 2018 Petrick. All rights reserved.
//

import UIKit

class UsageViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        loadInAppData()
    }
    
    //1) First
    func loadInAppData() {
        InAppManager.shared.delegate = self
        InAppManager.shared.requestProductInfo()
    }
    
    //2) Second
    func startPurchasing() {
        InAppManager.shared.triggerEvents()
    }
    
    //3) Third
    func restorePurchase() {
        InAppManager.shared.triggerEvents(true)
    }
}

extension UsageViewController : InAppManagerDelegate {
    func inappPrice(_ price: String?, request: Bool) {
        if request {
            print( "Show price in UI :",price ?? "")
            //yourLbl.text = price
        } else {
            print("Show Error")
        }
        //HideLoader
        
    }
    
    func inAppRestore(_ success: Bool, _ error: String?) {
        if success {
            print("Your Purchase restored")
        } else {
            print("Show Error")
        }
        //HideLoader
    }
    
    func inAppTransaction(_ success: Bool, _ error: String?) {
        if success {
            print("Purchase Complete")
        } else {
            //Show Error
        }
        //HideLoader
    }
    
    func inAppShowLoader() {
        //show Loader
    }
}
