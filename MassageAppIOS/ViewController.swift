//
//  ViewController.swift
//  massageApp
//
//  Created by сергей on 23/12/2018.
//  Copyright © 2018 сергей. All rights reserved.
//

import UIKit
import AVFoundation
import AudioToolbox
import GoogleMobileAds

class ViewController: UIViewController, UIScrollViewDelegate, GADBannerViewDelegate, GADRewardBasedVideoAdDelegate, SKPaymentTransactionObserver, SKProductsRequestDelegate {
    
    enum Mode {
        case dark
        case light
    }
    
    @IBOutlet weak var TitleLabel: UILabel!
    @IBOutlet weak var Background: UIImageView!
    
   
   
    @IBOutlet weak var AdBannerHeight: NSLayoutConstraint!
    var lastContentOffset = 0.0 as CGFloat
    
    let MAX_HEIGHT: CGFloat = 100.0
    let MAX_WIDTH: CGFloat = 350.0
    let MIN_HEIGHT: CGFloat = 50.0
    let MIN_WIDTH: CGFloat = 175.0
    
    let SCREEN_HEIGHT: CGFloat = UIScreen.main.bounds.height
    
    var mode : Mode = .light
    let i8 = 240
    let i8Plus = 200
    let iXs = 200
    let iXr = 160
    
    let IPHONE_8_HEIGHT : CGFloat = 667
    let IPHONE_8PLUS_HEIGHT: CGFloat = 736
    let IPHONE_XS_HEIGHT: CGFloat = 812
    let IPHONE_Xr_HEIGHT : CGFloat = 896
    
    var PlayingTag : Int = 0
    var currentTag : Int = 0
    
    var massage : Massage = Massage()
    
    var isPlaying : Bool = false
    var videoAdIsPlayed : Bool = false
    
    var subViewsArray : [UIView] = [UIView]()
    var progressViewsArray : [UIView] = [UIView]()
    var progressViewsConstraintsArray : [NSLayoutConstraint] = [NSLayoutConstraint]()
    var ButtonsArray: [UIButton] = [UIButton]()
    var ProVersionLayersArray : [Int : UIStackView] = [Int : UIStackView]()
    var i: CGFloat = 1.0
    
    var ProButton : UIButton = UIButton()
    var SoundButton : UIButton = UIButton()
    var DarkModeButton : UIButton = UIButton()
    
    var InfoButtonsArray : [UIButton] = [UIButton]()
    var isSoundEnabled : Bool = true
    
    var isProVersionPurchased : Bool = false
    var ProButtonsTagRange : ClosedRange<Int> = 3...8
    var WatchVideoButtonsArray : [UIButton] = [UIButton]()
    
  
    var disableProgressTimer = Timer()
    var hideProLayerTimer = Timer()
    
    @IBOutlet weak var OopsView: UIView!
    @IBOutlet weak var bannerView: GADBannerView!
    var BackSound : AVAudioPlayer!
    var soundTimer = Timer()
    
    
    
    var product : SKProduct?
    var productID = "com.juniorsoftcorp.MassageApp.proversion"
    
    var C_Values : [Int : CGFloat] = [2 : 98, 3: 188, 4: 278, 5: 353, 6:428, 7: 503, 8: 573, 9: 643, 10: 713]
    var soundpath : String? = ""
    @IBOutlet weak var scroll: UIScrollView!
    @IBOutlet weak var ScrollView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let device = UIDevice()
        if !device.DeviceHasTapticEngine() {
            OopsView.isHidden = false
        }else{
            OopsView.isHidden = true
        
        scroll.delegate = self
        initButtonViews(n: 10)
        initInfoButtons()
       
       
   
        soundpath = Bundle.main.path(forResource: "BackgroundSound", ofType: "mp3")
        do{
            try BackSound = AVAudioPlayer(contentsOf: URL(fileURLWithPath: soundpath!))
        }catch{
            print(error)
        }
        playSound()
      
        if UserDefaults.standard.bool(forKey: "ProVersion"){
            ProPurchased()
        }else{
            
        initAdBanner()
        initVideoAd()
        initProVersionLayer(range: ProButtonsTagRange)
            
        SKPaymentQueue.default().add(self)
        getPurchsedInfo()
            
        }
        }
    }
    
    
//    MARK: -In App Purchase
    func ProPurchased(){
        for i in ProButtonsTagRange{
            ProVersionLayersArray[i]?.isHidden = true
        }
        isProVersionPurchased = true
        ProButton.setImage(UIImage(named: "pro1.png"), for: .normal)
        ProButton.isEnabled = false
        AdBannerHeight.constant = 0
        bannerView.isHidden = true
    }
    
        @objc func GetPro(){
            let alert = UIAlertController(title: "Full Version", message: "Do you want to get all massage modes and disable Ad?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { _ in
                self.buyPro()
            }))
            alert.addAction(UIAlertAction(title: "Restore", style: .default, handler: { _ in SKPaymentQueue.default().restoreCompletedTransactions() }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            present(alert, animated: true, completion: nil)
        }
        
        
        func buyPro(){
            let payment = SKPayment(product: product!)
            SKPaymentQueue.default().add(payment)
        }
  
    
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
            for transaction in transactions{
                      switch transaction.transactionState {
                      case SKPaymentTransactionState.purchased:
                          SKPaymentQueue.default().finishTransaction(transaction)
                          UserDefaults.standard.setValue(true, forKey: "ProVersion")
                          ProPurchased()
                      case SKPaymentTransactionState.failed:
                          SKPaymentQueue.default().finishTransaction(transaction)
                          //CanCustomizeAlert = true
                      case SKPaymentTransactionState.restored:
                          SKPaymentQueue.default().finishTransaction(transaction)
                          UserDefaults.standard.setValue(true, forKey: "ProVersion")
                          ProPurchased()
                      default:
                         break
                      }
                  }
       }
       
       func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
                 let products = response.products
             
             if (products.count == 0){
            // message = FailAlertMessage
            
             }else{
                 product = products[0]
               //  message = product!.localizedDescription
               //  CanCustomizeAlert = true
             }
             
             let invalid = response.invalidProductIdentifiers
             for product in invalid{
                 print("\(product)")
             }
       }
    
    func getPurchsedInfo(){
           if SKPaymentQueue.canMakePayments(){
               let request = SKProductsRequest(productIdentifiers: NSSet(objects: self.productID) as! Set<String>)
               request.delegate = self
               request.start()
           }else{
              // ProVersionAlert.message = "Enable IAP on your device"
           }
       }
    
    
    
    
    func initVideoAd(){
        GADRewardBasedVideoAd.sharedInstance().delegate = self
        GADRewardBasedVideoAd.sharedInstance().load(GADRequest(), withAdUnitID: "ca-app-pub-3940256099942544/1712485313")
        
    }
    
    func rewardBasedVideoAd(_ rewardBasedVideoAd: GADRewardBasedVideoAd, didRewardUserWith reward: GADAdReward) {
        print("Reward received with currency: \(reward.type), amount \(reward.amount).")
        videoAdIsPlayed = true
        
    }
    
    func rewardBasedVideoAdDidClose(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
        if videoAdIsPlayed{
         makeMassage(tag: currentTag)
        }
        for button in WatchVideoButtonsArray{
            button.isEnabled = false
            button.alpha = 0.5
        }
      GADRewardBasedVideoAd.sharedInstance().load(GADRequest(),
          withAdUnitID: "ca-app-pub-3940256099942544/1712485313")
    }
    
    func rewardBasedVideoAdDidCompletePlaying(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
     // print("Reward based video ad has completed.")
       
    }
    
    func rewardBasedVideoAdDidReceive(_ rewardBasedVideoAd:GADRewardBasedVideoAd) {
        for button in WatchVideoButtonsArray{
            button.isEnabled = true
            button.alpha = 1
        }
    }
    
    func initAdBanner(){
        bannerView.isHidden = true
        bannerView.adSize = kGADAdSizeSmartBannerPortrait
        bannerView.delegate = self
        bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716"
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
               
    }
    
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        bannerView.isHidden = false
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
 
        for subView in subViewsArray{
            changeButtonView(subView, ScrollView: scrollView)
        }
        lastContentOffset = scrollView.contentOffset.y
        
    }
    
    
    func initInfoButtons(){
        
        let mult = SCREEN_HEIGHT == IPHONE_8PLUS_HEIGHT || SCREEN_HEIGHT == IPHONE_8_HEIGHT ? -15 : 40
        
        ProButton = UIButton(frame: CGRect(x: 0 , y: 0, width: 40.0, height: 40.0))
        ProButton.center.x = UIScreen.main.bounds.width/2
        ProButton.center.y = TitleLabel.center.y + TitleLabel.frame.height + CGFloat(mult)
        ProButton.setImage(UIImage(named: "pro2.png"), for: .normal)
        ProButton.addTarget(self, action: #selector(GetPro), for: .touchUpInside)
        
        SoundButton = UIButton(frame: CGRect(x: 0 , y: 0, width: 40.0, height: 40.0))
        SoundButton.center.x = ProButton.center.x + 70
        SoundButton.center.y = TitleLabel.center.y + TitleLabel.frame.height + CGFloat(mult)
        SoundButton.setImage(UIImage(named: "soundOn.png"), for: .normal)
        SoundButton.addTarget(self, action: #selector(sound), for: .touchUpInside)
        
        DarkModeButton = UIButton(frame: CGRect(x: 0 , y: 0, width: 40.0, height: 40.0))
        DarkModeButton.center.x = ProButton.center.x - 70
        DarkModeButton.center.y = TitleLabel.center.y + TitleLabel.frame.height + CGFloat(mult)
        DarkModeButton.setImage(UIImage(named: "DarkMode.png"), for: .normal)
        DarkModeButton.addTarget(self, action: #selector(darkMode), for: .touchUpInside)
        
        view.addSubview(ProButton)
        view.addSubview(SoundButton)
        view.addSubview(DarkModeButton)
        
    }
    
    @objc func darkMode(sender: UIButton!){
        
        if mode == .light{  //switching to dark mode
            mode = .dark
            
            DarkModeButton.setImage(#imageLiteral(resourceName: "LightMode"), for: .normal)
            
            
            isSoundEnabled ? SoundButton.setImage(#imageLiteral(resourceName: "soundOn_Dark"), for: .normal) : SoundButton.setImage(#imageLiteral(resourceName: "soundOff_Dark"), for: .normal)
            if !isProVersionPurchased{
                ProButton.setImage(#imageLiteral(resourceName: "pro2_Dark"), for: .normal)
            }
            for i in 0..<ButtonsArray.count{
                ButtonsArray[i].setImage(UIImage(named: "btn\(i+1)_Dark.png"), for: .normal)
                progressViewsArray[i].backgroundColor = .brown
            }
            
            TitleLabel.textColor = #colorLiteral(red: 0.6558870673, green: 0.6145125628, blue: 0.7663239837, alpha: 1)
            Background.image = #imageLiteral(resourceName: "Back_Dark")
            
        }else{   //switching to light mode
            mode = .light
            
            DarkModeButton.setImage(#imageLiteral(resourceName: "DarkMode"), for: .normal)
            isSoundEnabled ? SoundButton.setImage(#imageLiteral(resourceName: "soundOn"), for: .normal) : SoundButton.setImage(#imageLiteral(resourceName: "soundOff"), for: .normal)
            if !isProVersionPurchased{
                ProButton.setImage(#imageLiteral(resourceName: "pro2"), for: .normal)
            }
            
            for i in 0..<ButtonsArray.count{
                ButtonsArray[i].setImage(UIImage(named: "btn\(i+1).png"), for: .normal)
                progressViewsArray[i].backgroundColor = .purple
            }
            TitleLabel.textColor = #colorLiteral(red: 0, green: 0.311291486, blue: 0, alpha: 1)
            Background.image = #imageLiteral(resourceName: "back 4")
            
        }
        
        
        
    }
    
   
    
    
    @objc func sound(sender : UIButton!){
        if mode == .dark{
            if isSoundEnabled{
                isSoundEnabled = false
                SoundButton.setImage(#imageLiteral(resourceName: "soundOff_Dark"), for: .normal)
                BackSound.stop()
                soundTimer.invalidate()
            }else{
                isSoundEnabled = true
                SoundButton.setImage(#imageLiteral(resourceName: "soundOn_Dark"), for: .normal)
                playSound()
            }
        }else{
            if isSoundEnabled{
                isSoundEnabled = false
                SoundButton.setImage(#imageLiteral(resourceName: "soundOff"), for: .normal)
                BackSound.stop()
                soundTimer.invalidate()
            }else{
                isSoundEnabled = true
                SoundButton.setImage(#imageLiteral(resourceName: "soundOn"), for: .normal)
                playSound()
            }
        }
    }
    
    
    @objc func repeatSound(){
           BackSound.stop()
           BackSound.currentTime = 0
           BackSound.play()
           BackSound.volume = 0.6
       }
       
       func playSound(){
           soundTimer.invalidate()
           BackSound.stop()
           BackSound.currentTime = 0
           BackSound.play()
           BackSound.volume = 0.6
           soundTimer = Timer.scheduledTimer(timeInterval: 50, target: self, selector: #selector(repeatSound), userInfo: nil, repeats: true)
       }
    
    

    
    // Returns middle of scrollView height for each device
    func getMid() -> Int{
        switch SCREEN_HEIGHT{
        case IPHONE_8_HEIGHT:
            return  i8
        case IPHONE_8PLUS_HEIGHT:
            return  i8Plus
        case IPHONE_XS_HEIGHT:
            return iXs
        case IPHONE_Xr_HEIGHT:
            return iXr
        default:
            return 100
        }
    }
    
    func initButtonViews(n: Int){
        for i in 1...n{
            let width = MAX_WIDTH - CGFloat(30*(i-1))
            let height = width/3.5
            let newView = UIView(frame: CGRect(x: 0, y: 0, width: width, height: height ))
            
            ScrollView.addSubview(newView)
            
            newView.backgroundColor = .clear
            newView.layer.cornerRadius = 5
            newView.center.x = UIScreen.main.bounds.width/2
            
            let mid = getMid()
            if subViewsArray.count == 0 {
                newView.center.y = scroll.center.y - CGFloat(mid)
            }else{
                newView.center.y = (subViewsArray.last!.center.y) + (subViewsArray.last!.frame.height)*1.2
                
            }
            
            subViewsArray.append(newView)
            ButtonsArray.append(UIButton())
            progressViewsArray.append(UIView())
            newView.addSubview(progressViewsArray[i-1])
            
            progressViewsArray[i-1].progressViewInit(newView)
            newView.addSubview(ButtonsArray[i-1])
            ButtonsArray[i-1].customInit(newView)
            ButtonsArray[i-1].setImage(UIImage(named: "btn" + String(i)), for: .normal)
            ButtonsArray[i-1].addTarget(self, action: #selector(MassageBtn), for: .touchUpInside)
            ButtonsArray[i-1].tag = i - 1
            
            let constraint = progressViewsArray[i-1].rightAnchor.constraint(equalTo: newView.rightAnchor)
            constraint.constant = 0 - newView.frame.width
            constraint.isActive = true
            progressViewsConstraintsArray.append(constraint)
        }
    }
    
    
    func changeButtonView(_ View: UIView, ScrollView scrollView : UIScrollView){
        
        var height = View.frame.height
        var width = View.frame.width
        var c: CGFloat = 90*(i-1)
        if i > 1 && i<11{
            c = C_Values[Int(i)]!
        }
        width = MAX_WIDTH - 1/3*abs(scrollView.contentOffset.y - c)
        height = width/3.5
        if height >= MAX_HEIGHT  || width >= MAX_WIDTH - 0.333  {
            height = MAX_HEIGHT
            width = MAX_WIDTH

            

        } else if height < MIN_HEIGHT/i || width < MIN_WIDTH/i {
            height = MIN_HEIGHT/i
            width = MIN_WIDTH/i
        }
        View.frame = CGRect(x: 0, y: View.frame.origin.y, width: CGFloat(width), height: CGFloat(height))
        
        View.center.x = scrollView.center.x
        
        if ButtonsArray[Int(i)-1].tag != PlayingTag || ( !isPlaying && ButtonsArray[Int(i)-1].tag == PlayingTag) {
        progressViewsConstraintsArray[Int(i)-1].constant = -width
        }
       
        if i > 1{
            View.center.y = subViewsArray[Int(i)-2].center.y + subViewsArray[Int(i)-2].frame.height*1.2
        }
        if i < 10{
            i = i + 1
        }else{
            i = 1
        }
    }
    
    
    @objc func MassageBtn(sender : UIButton!){
        
        if isProVersionPurchased || !ProButtonsTagRange.contains(sender!.tag) || PlayingTag == sender!.tag && isPlaying {
            makeMassage(tag: sender!.tag)
        }else{
            ProVersionLayersArray[sender!.tag]?.isHidden = false
            hideProLayerTimer = Timer.scheduledTimer(withTimeInterval: 8, repeats: false, block: { _ in
                self.ProVersionLayersArray[sender!.tag]?.isHidden = true})
        }

    }
    
    
    func makeMassage(tag : Int){
        disableProgressTimer.invalidate()
        massage.stop()
        massage = Massage(mode: tag)
        videoAdIsPlayed = false
        
        print(progressViewsConstraintsArray[tag].constant)
        progressViewsArray[PlayingTag].layer.removeAllAnimations()
        if isPlaying{
            //Stops playing
            if PlayingTag == tag{
                progressViewsConstraintsArray[tag].constant = -progressViewsArray[tag].frame.width
                view.layoutIfNeeded()
            
                isPlaying = false
            }else{
                progressViewsConstraintsArray[PlayingTag].constant = -progressViewsArray[PlayingTag].frame.width
                view.layoutIfNeeded()
                progressViewsConstraintsArray[tag].constant = 0//-progressViewsArray[sender!.tag].frame.width
                massage.play()
                UIView.animate(withDuration: massage.duration, animations: {
                    print("start")
                    self.view.layoutIfNeeded()
                })
                disableProgressTimer = Timer.scheduledTimer(withTimeInterval: massage.duration, repeats: false, block: { _ in
                    self.progressViewsConstraintsArray[tag].constant = -self.progressViewsArray[tag].frame.width
                    self.view.layoutIfNeeded()
                    self.isPlaying = false
                    if !self.isProVersionPurchased{
                    self.bannerView.load(GADRequest())
                    }
                })
                 isPlaying = true
            }
        }else{
             isPlaying = true
            progressViewsConstraintsArray[tag].constant = 0// -progressViewsArray[sender!.tag].frame.width
            massage.play()
            UIView.animate(withDuration: massage.duration, animations: {
                self.view.layoutIfNeeded()
                print("start")
                print(self.progressViewsConstraintsArray[tag].constant)
            })
            disableProgressTimer = Timer.scheduledTimer(withTimeInterval: massage.duration, repeats: false, block: { _ in
                self.progressViewsConstraintsArray[tag].constant = -self.progressViewsArray[tag].frame.width
                self.view.layoutIfNeeded()
                self.isPlaying = false
               if !self.isProVersionPurchased{
                self.bannerView.load(GADRequest())
                }
            })
            
        }
        
        
        PlayingTag = tag
    }
    
    func initProVersionLayer(range : ClosedRange<Int>){
        
        ProButtonsTagRange = range
        
        for i in range{
           
            
            let stack = UIStackView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
            ProVersionLayersArray[i] = stack
            stack.translatesAutoresizingMaskIntoConstraints = false
            subViewsArray[i].addSubview(stack)
            
            stack.axis = .horizontal
            stack.distribution = .fillEqually
            stack.spacing = 2
            stack.addBackground(color: #colorLiteral(red: 0.3972967565, green: 0.3821620047, blue: 0.3771889508, alpha: 0.8291952055))
            stack.layer.cornerRadius = 5
            
            stack.topAnchor.constraint(equalTo: subViewsArray[i].topAnchor, constant: 0).isActive = true
            stack.bottomAnchor.constraint(equalTo: subViewsArray[i].bottomAnchor, constant: 0).isActive = true
            stack.trailingAnchor.constraint(equalTo: subViewsArray[i].trailingAnchor, constant: 0).isActive = true
            stack.leadingAnchor.constraint(equalTo: subViewsArray[i].leadingAnchor, constant: 0).isActive = true
            
            
            let videoBtn = UIButton()
            videoBtn.initProLayerButton(title: "Watch Ad", tag: i)
            videoBtn.addTarget(self, action: #selector(watchVideo), for: .touchUpInside)
            videoBtn.isEnabled = false
            videoBtn.alpha = 0.5
            WatchVideoButtonsArray.append(videoBtn)
            let proBtn = UIButton()
            proBtn.initProLayerButton(title: "Get Pro", tag: i)
            proBtn.addTarget(self, action: #selector(GetPro), for: .touchUpInside)
            stack.isHidden = true
            stack.addArrangedSubview(proBtn)
            stack.addArrangedSubview(videoBtn)
            
        }
        
    }

  @objc func watchVideo(sender : UIButton!){
    ProVersionLayersArray[sender!.tag]?.isHidden = true
    currentTag = sender!.tag
   // makeMassage(tag: sender!.tag)
    if GADRewardBasedVideoAd.sharedInstance().isReady == true {
      GADRewardBasedVideoAd.sharedInstance().present(fromRootViewController: self)
    }
  }


}




extension UIStackView {
    func addBackground(color: UIColor) {
        let subView = UIView(frame: bounds)
        subView.backgroundColor = color
        subView.layer.cornerRadius = 5
        subView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        insertSubview(subView, at: 0)
    }
}


extension UIButton {
    func customDesign(){
        self.layer.cornerRadius = self.frame.height/4
    }
    
    func customInit( _ parentView: UIView){
        self.frame = CGRect(x: 0, y: 0, width: parentView.frame.width, height: parentView.frame.height)
        
        self.translatesAutoresizingMaskIntoConstraints = false
        self.leftAnchor.constraint(equalTo: parentView.leftAnchor, constant: 0).isActive = true
        self.rightAnchor.constraint(equalTo: parentView.rightAnchor, constant: 0).isActive = true
        self.topAnchor.constraint(equalTo: parentView.topAnchor, constant: 0).isActive = true
        self.bottomAnchor.constraint(equalTo: parentView.bottomAnchor, constant: 0).isActive = true
        self.layer.cornerRadius = 5
        self.alpha = 1
    }
    
    
    func initProLayerButton(title: String, tag i: Int){
        self.setTitle(title, for: .normal)
        self.titleLabel?.font = UIFont(name: "Hiragino Maru Gothic ProN", size: 20)
        self.tag = i
        self.layer.borderWidth = 2
        self.layer.borderColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        self.layer.cornerRadius = 5
    }
    
}

extension UIView {
    func progressViewInit(_ parentView : UIView){
            self.frame = CGRect(x: 0, y: 0, width: 0, height: parentView.frame.height)
            self.translatesAutoresizingMaskIntoConstraints = false
            self.leftAnchor.constraint(equalTo: parentView.leftAnchor, constant: 0).isActive = true
        
            self.topAnchor.constraint(equalTo: parentView.topAnchor, constant: 0).isActive = true
            self.bottomAnchor.constraint(equalTo: parentView.bottomAnchor, constant: 0).isActive = true
        
        
            self.backgroundColor = .purple
            self.layer.cornerRadius = 5
     
    }
}

public extension UIDevice {

    static let modelName: String = {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }

        func mapToDevice(identifier: String) -> String { // swiftlint:disable:this cyclomatic_complexity
            #if os(iOS)
            switch identifier {
            case "iPod5,1":                                 return "iPod touch (5th generation)"
            case "iPod7,1":                                 return "iPod touch (6th generation)"
            case "iPod9,1":                                 return "iPod touch (7th generation)"
            case "iPhone3,1", "iPhone3,2", "iPhone3,3":     return "iPhone 4"
            case "iPhone4,1":                               return "iPhone 4s"
            case "iPhone5,1", "iPhone5,2":                  return "iPhone 5"
            case "iPhone5,3", "iPhone5,4":                  return "iPhone 5c"
            case "iPhone6,1", "iPhone6,2":                  return "iPhone 5s"
            case "iPhone7,2":                               return "iPhone 6"
            case "iPhone7,1":                               return "iPhone 6 Plus"
            case "iPhone8,1":                               return "iPhone 6s"
            case "iPhone8,2":                               return "iPhone 6s Plus"
            case "iPhone9,1", "iPhone9,3":                  return "iPhone 7"
            case "iPhone9,2", "iPhone9,4":                  return "iPhone 7 Plus"
            case "iPhone8,4":                               return "iPhone SE"
            case "iPhone10,1", "iPhone10,4":                return "iPhone 8"
            case "iPhone10,2", "iPhone10,5":                return "iPhone 8 Plus"
            case "iPhone10,3", "iPhone10,6":                return "iPhone X"
            case "iPhone11,2":                              return "iPhone XS"
            case "iPhone11,4", "iPhone11,6":                return "iPhone XS Max"
            case "iPhone11,8":                              return "iPhone XR"
            case "iPhone12,1":                              return "iPhone 11"
            case "iPhone12,3":                              return "iPhone 11 Pro"
            case "iPhone12,5":                              return "iPhone 11 Pro Max"
            case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":return "iPad 2"
            case "iPad3,1", "iPad3,2", "iPad3,3":           return "iPad (3rd generation)"
            case "iPad3,4", "iPad3,5", "iPad3,6":           return "iPad (4th generation)"
            case "iPad6,11", "iPad6,12":                    return "iPad (5th generation)"
            case "iPad7,5", "iPad7,6":                      return "iPad (6th generation)"
            case "iPad7,11", "iPad7,12":                    return "iPad (7th generation)"
            case "iPad4,1", "iPad4,2", "iPad4,3":           return "iPad Air"
            case "iPad5,3", "iPad5,4":                      return "iPad Air 2"
            case "iPad11,4", "iPad11,5":                    return "iPad Air (3rd generation)"
            case "iPad2,5", "iPad2,6", "iPad2,7":           return "iPad mini"
            case "iPad4,4", "iPad4,5", "iPad4,6":           return "iPad mini 2"
            case "iPad4,7", "iPad4,8", "iPad4,9":           return "iPad mini 3"
            case "iPad5,1", "iPad5,2":                      return "iPad mini 4"
            case "iPad11,1", "iPad11,2":                    return "iPad mini (5th generation)"
            case "iPad6,3", "iPad6,4":                      return "iPad Pro (9.7-inch)"
            case "iPad6,7", "iPad6,8":                      return "iPad Pro (12.9-inch)"
            case "iPad7,1", "iPad7,2":                      return "iPad Pro (12.9-inch) (2nd generation)"
            case "iPad7,3", "iPad7,4":                      return "iPad Pro (10.5-inch)"
            case "iPad8,1", "iPad8,2", "iPad8,3", "iPad8,4":return "iPad Pro (11-inch)"
            case "iPad8,5", "iPad8,6", "iPad8,7", "iPad8,8":return "iPad Pro (12.9-inch) (3rd generation)"
            case "AppleTV5,3":                              return "Apple TV"
            case "AppleTV6,2":                              return "Apple TV 4K"
            case "AudioAccessory1,1":                       return "HomePod"
            case "i386", "x86_64":                          return "Simulator \(mapToDevice(identifier: ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] ?? "iOS"))"
            default:                                        return identifier
            }
            #elseif os(tvOS)
            switch identifier {
            case "AppleTV5,3": return "Apple TV 4"
            case "AppleTV6,2": return "Apple TV 4K"
            case "i386", "x86_64": return "Simulator \(mapToDevice(identifier: ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] ?? "tvOS"))"
            default: return identifier
            }
            #endif
        }

        return mapToDevice(identifier: identifier)
    }()

    
    func DeviceHasTapticEngine() -> Bool{
        
        var name = UIDevice.modelName.split(separator: " ")
        if name[0] == "Simulator"{
            name.remove(at: 0)
        }
        if name[0] == "iPhone"{
            if name[1] == "6" || name[1] == "5s" || name[1] == "4s" || name[1] == "4" || name[1] == "5c" || name[1] == "SE"{
                return false
            }else{
            return true
            }
            }else{
            return false
            }
        
        
    }
    
    
}
