

import UIKit

class ProVersionAlert {
    
   
    var alert = UIAlertController()

    
    init(){
       
        alert = UIAlertController(title: "Pro Version", message: "Unlock all massage modes and remove Ads", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Get", style: .default, handler: GetPro()))
        alert.addAction(UIAlertAction(title: "Restore", style: .default, handler: Restore()))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
    }
    

    
    func GetPro() -> ((UIAlertAction) -> Void)? {
        print("Pro is Here")
        
    return nil
    }
    
    func Restore() -> ((UIAlertAction) -> Void)? {
        print("Restore pressed")
        
    return nil
    }
    
}
