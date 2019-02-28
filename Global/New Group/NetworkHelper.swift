import Foundation
import Alamofire
import UIKit
import SwiftyJSON
import NVActivityIndicatorView

public class NetworkHelper : UIViewController {
    
    @available(*, deprecated, message: "use shareWithPars: instead")

    public static func shareWithPars(parameter: Any? ,method: HTTPMethod, url: String, completion: @escaping (_ result: [String : Any]) -> Void, completionError: @escaping (_ error:  [String : Any]) -> Void)  {
        let status = Reachability.isConnectedToNetwork()
        switch status {
        case .unknown,.offline:
            let errorDist = ["errorType":1, "errorValue": kNoInterNetMessage] as [String : Any]
            completionError(errorDist as [String : Any])
            break
        case .online(.wwan),.online(.wiFi):
           let headers: NSMutableDictionary = self.headerDictionary()
           Alamofire.request(url, method: method, parameters: parameter as? Parameters, encoding: URLEncoding.default, headers: nil).responseJSON { response in
                    if response.result.isSuccess {
                        print(response)
                        NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
                        if let json = response.result.value {
                            if let jsonObjects = json as? [String: Any] {
                                completion(jsonObjects )
                            }
                        } else if let error = response.result.error {
                            NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
                            let errorDist = ["errorType":2, "errorValue": kSomethingGetWrong] as [String : Any]
                            completionError(errorDist as [String : AnyObject])
                        }
                    } else {
                        NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
                        let errorDist = ["errorType":3, "errorValue": kSomethingGetWrong] as [String : Any]
                        completionError(errorDist as [String : Any])
                    }
            }
            break
        }
    }
    func getPostString(params:[String:Any]) -> String
    {
        var data = [String]()
        for(key, value) in params
        {
            data.append(key + "=\(value)")
        }
        return data.map { String($0) }.joined(separator: "&")
    }

    public static func headerDictionary()-> NSMutableDictionary {
        let headers: NSMutableDictionary = NSMutableDictionary()
        headers.setValue("application/json", forKey: "Content-Type")
        return headers
    }
    
}
