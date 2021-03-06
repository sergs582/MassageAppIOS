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

class ViewController: UIViewController, UIScrollViewDelegate, GADBannerViewDelegate, GADRewardedAdDelegate, SKPaymentTransactionObserver, SKProductsRequestDelegate {
    
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
    var isProPurchaseEnabled = false
    
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
    var ProButtonsTagRange : ClosedRange<Int> = 4...8
    var WatchVideoButtonsArray : [UIButton] = [UIButton]()
    
  
    var disableProgressTimer = Timer()
    var hideProLayerTimer = Timer()
    
    @IBOutlet weak var OopsView: UIView!
    @IBOutlet weak var bannerView: GADBannerView!
    var rewardedAd: GADRewardedAd?
    
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
            if isProPurchaseEnabled {
                alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { _ in
                    self.buyPro()
                }))
                alert.addAction(UIAlertAction(title: "Restore", style: .default, handler: { _ in SKPaymentQueue.default().restoreCompletedTransactions() }))
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            }else{
                
                alert.message = "Problems with internet connection. Try again later"
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            }
            
            
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
                isProPurchaseEnabled = false
            
             }else{
                 product = products[0]
               //  message = product!.localizedDescription
               //  CanCustomizeAlert = true
                isProPurchaseEnabled = true
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

    func initVideoAd() {
        rewardedAd = GADRewardedAd(adUnitID: "ca-app-pub-5510822664979086/7642804651")
        loadVideoAd()
    }
    
    func loadVideoAd() {
        rewardedAd?.load(GADRequest()) { error in
            if let error = error {
                print("Error in initializing Video AD: \(error.localizedDescription)")
            } else {
                print("Video AD Successfully initialized")
                for button in self.WatchVideoButtonsArray{
                    button.isEnabled = true
                    button.alpha = 1
                }
            }
        }
    }
    
    func rewardedAd(_ rewardedAd: GADRewardedAd, userDidEarn reward: GADAdReward) {
        print("Reward received with currency: \(reward.type), amount \(reward.amount).")
        videoAdIsPlayed = true
    }
    
    func rewardedAdDidDismiss(_ rewardedAd: GADRewardedAd) {
        if videoAdIsPlayed{
         makeMassage(tag: currentTag)
        }
        for button in WatchVideoButtonsArray{
            button.isEnabled = false
            button.alpha = 0.5
        }
        initVideoAd()
    }
    
    func initAdBanner(){
        bannerView.isHidden = true
        bannerView.adUnitID = "ca-app-pub-5510822664979086/1001280856"
        bannerView.adSize = kGADAdSizeSmartBannerPortrait
        bannerView.delegate = self
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
    if rewardedAd?.isReady == true {
      rewardedAd?.present(fromRootViewController: self, delegate: self)
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
