//
//  InAppManager.swift
//  Wally
//
//  Created by Petrick on 30/08/18.
//  Copyright © 2018 Petrick. All rights reserved.
//

import UIKit
import StoreKit


protocol InAppManagerDelegate : class {
    func inappPrice(_ price :String?, request : Bool)
    func inAppTransaction(_ success : Bool, _ error : String?)
    func inAppRestore(_ success : Bool, _ error : String?)
    func inAppShowLoader()
}

class InAppManager: NSObject, SKPaymentTransactionObserver {

    static var shared = InAppManager()
    let productID = "com.app.com.YourProductID"
    var transactionInProgress = false
    var delegate : InAppManagerDelegate?
    var product : SKProduct?
    
    
    override init() {
        super.init()
        
        SKPaymentQueue.default().add(self)
    }
    
    func requestProductInfo() {
        
        if !ReachabilityX.isInternetConnected() {
            delegate?.inappPrice(nil, request: false)
            return
        }
        
        if SKPaymentQueue.canMakePayments() {
            let productIdentifiers : NSSet = NSSet(array: [productID])
            let productRequest = SKProductsRequest(productIdentifiers: productIdentifiers as! Set<String>)
            productRequest.delegate = self
            productRequest.start()
        } else {
            print("Cannot perform In App Purchases.")
            delegate?.inappPrice(nil, request: false)
        }
    }
    
    func triggerEvents(_ isForRestore : Bool = false) {
        
        if product == nil {
            //Load Product
            requestProductInfo()
        } else {
            if isForRestore {
                delegate?.inAppShowLoader()
                goForRestore()
            } else {
                //Make Purchase
                delegate?.inAppShowLoader()
                goForPurchase()
            }
        }
        
    }
    
    func goForPurchase() {
        
        if let product = product, !transactionInProgress {
            let payment = SKPayment(product: product)
            transactionInProgress = true
            SKPaymentQueue.default().add(payment)
        }
    }
    
    func goForRestore() {
        if (SKPaymentQueue.canMakePayments()) {
            SKPaymentQueue.default().add(self)
            SKPaymentQueue.default().restoreCompletedTransactions()
        } else {
            // show error
            delegate?.inAppRestore(false, nil)
        }
    }
    
    //MARK:- Payment Observer
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions  {
            switch transaction.transactionState {
            case SKPaymentTransactionState.purchased:
                print("Transaction completed successfully.")
                SKPaymentQueue.default().finishTransaction(transaction)
                transactionInProgress = false
                delegate?.inAppTransaction(true, nil)
                break
            case SKPaymentTransactionState.failed:
                print("Transaction Failed");
                SKPaymentQueue.default().finishTransaction(transaction)
                transactionInProgress = false
                delegate?.inAppTransaction(false, "Failed")
                break
            case .restored:
                print("Already Purchased")
                //Do unlocking etc stuff here in case of restor
                SKPaymentQueue.default().finishTransaction(transaction)
                delegate?.inAppRestore(true, nil)
                break
                
            default:
                print(transaction.transactionState.rawValue)
                //delegate?.inAppTransaction(false, "Failed")
            }
        }
    }
    
    func request(_ request: SKRequest, didFailWithError error: Error) {
        delegate?.inAppTransaction(false, "Failed")
    }
    
}


extension InAppManager : SKProductsRequestDelegate {
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        if response.products.count != 0 {
            for product in response.products {
                
                let formatter = NumberFormatter()
                formatter.numberStyle = .currency
                formatter.locale = product.priceLocale
                self.product = product
                if let cost = formatter.string(from: product.price) {
                    delegate?.inappPrice(cost, request: true)
                }
            }
        }
        else {
            print("There are no products.")
            delegate?.inappPrice(nil, request: false)
        }
        
        if response.invalidProductIdentifiers.count != 0 {
            print(response.invalidProductIdentifiers.description)
            delegate?.inappPrice(nil, request: false)
        }
    }
    
    
}
