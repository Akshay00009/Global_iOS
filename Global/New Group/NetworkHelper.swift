import Foundation
import Alamofire
import UIKit
import SwiftyJSON

public class NetworkHelper : UIViewController {
    
    @available(*, deprecated, message: "use shareWithPars: instead")

    public static func shareWithPars(parameter:NSDictionary? ,method: HTTPMethod, url: String, completion: @escaping (_ result: [String : Any]) -> Void, completionError: @escaping (_ error:  [String : Any]) -> Void)  {
        let status = Reachability.isConnectedToNetwork()
        switch status {
        case .unknown,.offline:
            let errorDist = ["errorType":1, "errorValue": kNoInterNetMessage] as [String : Any]
            completionError(errorDist as [String : Any])
            break
        case .online(.wwan),.online(.wiFi):
         //   let headers: NSMutableDictionary = self.headerDictionary()
            Alamofire.request(url, method: method, parameters: nil, encoding: JSONEncoding.default, headers: nil).responseJSON { response in
                    if response.result.isSuccess {
                        print(response)
                        if let json = response.result.value {
                            if let jsonObjects = json as? [String: Any] {
                                completion(jsonObjects )
                            }
                        }
                    } else if let error = response.result.error {
                        let errorDist = ["errorType":2, "errorValue": error] as [String : Any]
                        completionError(errorDist as [String : AnyObject])
                    }
            }
            break
        }
    }

    public static func headerDictionary()-> NSMutableDictionary {
        let headers: NSMutableDictionary = NSMutableDictionary()
        headers.setValue("application/json", forKey: "Content-Type")
        return headers
    }
    
}
