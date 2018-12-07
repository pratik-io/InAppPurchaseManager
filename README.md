# InAppPurchaseManager
InAppManager.swift  for InApp purchase to manage transactions in application.

# Just call method
call `loadInAppData` to load inapp data 

    func loadInAppData() {
        InAppManager.shared.delegate = self
        InAppManager.shared.requestProductInfo()
    }

call `startPurchasing` to start transaction

    //2) Second
    func startPurchasing() {
        InAppManager.shared.triggerEvents()
    }
