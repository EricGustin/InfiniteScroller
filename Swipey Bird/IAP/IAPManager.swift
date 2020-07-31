//
//  IAPManager.swift
//  Swipey Bird
//
//  Created by Eric Gustin on 7/29/20.
//  Copyright © 2020 Eric Gustin. All rights reserved.
//

import StoreKit

class IAPManager: NSObject {
  
  static let shared = IAPManager() // Allows for only one instance of the IAPManager to be created since init is private
  
  var onReceiveProductsHandler: ((Result<[SKProduct], IAPManagerError>) -> Void)?
  
  private override init() {
    super.init()
  }
  
  enum IAPManagerError: Error {
    case noProductIDsFound
    case noProductsFound
    case paymentWasCancelled
    case productRequestFailed
  }
  
  fileprivate func getProductIDs() -> [String]? {  // currently, there is only 1 product ID so this is an array of length 1
    guard let url = Bundle.main.url(forResource: "IAP_ProductsIDs", withExtension: "plist") else { return nil }
    do {
      let data = try Data(contentsOf: url)
      let productIDs = try PropertyListSerialization.propertyList(from: data, options: .mutableContainersAndLeaves, format: nil) as? [String] ?? []
      return productIDs
    } catch {
      print(error.localizedDescription)
      return nil
    }
  }
  
  func getProducts(withHandler productsReceiveHandler: @escaping (_ result: Result<[SKProduct], IAPManagerError>) -> Void) {
    // Result carries the collection of fetched products from the App Store if success, otherwise
    // it will carry a IAPManagerError on failure
    onReceiveProductsHandler = productsReceiveHandler
    
    guard let productIDs = getProductIDs() else {
      productsReceiveHandler(.failure(.noProductsFound))
      return
    }
    
    let request = SKProductsRequest(productIdentifiers: Set(productIDs))
    request.delegate = self
    request.start()
  }
  
  func getPriceFormatted(for product: SKProduct) -> String? {
      let formatter = NumberFormatter()
      formatter.numberStyle = .currency
      formatter.locale = product.priceLocale
      return formatter.string(from: product.price)
  }
  
}

extension IAPManager.IAPManagerError: LocalizedError {
  var errorDescription: String? {
    switch self {
      case .noProductIDsFound: return "No in-app purchase product identifiers were found."
      case .noProductsFound: return "No in app purchases were found."
      case .productRequestFailed: return "Unable to fetch availabe in app purchase products at the moment."
      case .paymentWasCancelled: return "In app purchase process was cancelled."
    }
  }
}

extension IAPManager: SKProductsRequestDelegate {
  func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
    let products = response.products
    if products.count > 0 {
      onReceiveProductsHandler?(.success(products))
    } else {
      onReceiveProductsHandler?(.failure(.noProductsFound))
    }
  }
  
  // delegate method that tells me if the request failed from soe reason
  func request(_ request: SKRequest, didFailWithError error: Error) {
    onReceiveProductsHandler?(.failure(.productRequestFailed))
  }
}
