//
//  ViewController.swift
//  YAPIDemo
//
//  Created by Daniel Seitz on 9/26/16.
//  Copyright © 2016 Daniel Seitz. All rights reserved.
//

import UIKit
import YAPI
import CoreLocation

class ViewController: UIViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    
    /*
    let parameters = YelpV3TokenParameters(grantType: .clientCredentials, clientId: "YvxjDSJzUHNbMDcxZ-1XTQ", clientSecret: "l79vZwLjzgoO9Gt6N6Gs6H5NJ85VBL1OOksSpfZTuvbcYzpqeGr3jzT7XNbYzBy5")
    let tokenAuthRequest = APIFactory.V3.makeTokenRequest(with: parameters)
    tokenAuthRequest.send { (response, error) in
      if let error = error {
        print(error)
      }
      print(response?.accessToken)
    }
    */
    let searchParameters = YelpV3SearchParameters(location: YelpV3LocationParameter(location: "Portland, OR"), limit: 40)
    APIFactory.V3.authenticate(appId: appId, clientSecret: clientSecret) { error in
      if let error = error {
        print("Error: \(error)")
      }
      else {
        print("Authenticated!")
//        let searchParameters = YelpV3SearchParameters(location: YelpV3LocationParameter(latitude: 45.509523, longitude: -122.679544))
        let request = APIFactory.V3.makeSearchRequest(with: searchParameters)
        request.send { result in
          switch result {
          case .ok(let response):
            for business in response.businesses {
              print("\(business.name)\n")
            }
          case .err(let error):
            print("Error: \(error)")
          }
        }
      }
    }
    let unauthedRequest = APIFactory.V3.makeSearchRequest(with: searchParameters)
    
    unauthedRequest.send { result in
      
      if case .err(let error) = result {
        print("Error received: \(error)")
      }
    }
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }


}

