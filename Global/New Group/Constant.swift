import Foundation
import UIKit


let kNoInterNetMessage = "No Internet Connection"
let kSomethingGetWrong = "Something Went Wrong"
let KLoginFailed = "Failed to Login."
let kActivityIndicatorSize = CGSize(width: 50, height: 50)
let kLoadingMessageForHud  = "Loading..."
let kActivityIndicatorNumber = 6

var loggedInUserID = ""

open class AppUtility {
    static func heightForView(text: String = "", width: CGFloat) -> CGFloat{
        let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.text = text
        label.sizeToFit()
        return label.frame.height
    }
    static func showInternetErrorMessage(title: String, errorMessage: String, completion: (() -> Void)!) -> UIAlertController {
        let alertTitle = title != "" ? "Oops.." : ""
        let alertController = UIAlertController(title: alertTitle, message: errorMessage, preferredStyle: UIAlertController.Style.alert)
        let retryAction = UIAlertAction(title: "Retry", style: UIAlertAction.Style.default, handler: {
            alert -> Void in
            completion()
        })
        alertController.addAction(retryAction)
        return alertController
    }

}

struct FontStyle {
    struct FontName {
        static let kDefault = "Lato"
        static let kDefaultBold = "Lato-Bold"
        static let kCustom = "Lato"
    }
    struct FontSize {
        static let kDefault: CGFloat = 17.0
    }
}

//************Extentions*****************************************

//Load Url Images
extension UIImageView {
    func load(url: URL) {
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.image = image
                    }
                }
            }
        }
    }
}

// IBInspectible
extension UIView {
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
    @IBInspectable var borderWidth: CGFloat {

        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    @IBInspectable var borderColor:UIColor? {
        set {
            layer.borderColor = newValue!.cgColor
        }
        get {
            if let color = layer.borderColor {
                return UIColor(cgColor: color)
            }
            else {
                return nil
            }
        }
    }
}
