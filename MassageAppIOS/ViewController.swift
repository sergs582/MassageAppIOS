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

class ViewController: UIViewController, UIScrollViewDelegate, GADBannerViewDelegate {
    
    @IBOutlet weak var TitleLabel: UILabel!
    
    var lastContentOffset = 0.0 as CGFloat
    
    let MAX_HEIGHT: CGFloat = 100.0
    let MAX_WIDTH: CGFloat = 350.0
    let MIN_HEIGHT: CGFloat = 50.0
    let MIN_WIDTH: CGFloat = 175.0
    
    let SCREEN_HEIGHT: CGFloat = UIScreen.main.bounds.height
    
    
    let i8 = 240
    let i8Plus = 200
    let iXs = 200
    let iXr = 160
    
    let IPHONE_8_HEIGHT : CGFloat = 667
    let IPHONE_8PLUS_HEIGHT: CGFloat = 736
    let IPHONE_XS_HEIGHT: CGFloat = 812
    let IPHONE_Xr_HEIGHT : CGFloat = 896
    
    var PlayingTag : Int = 0
    
    var massage : Massage = Massage()
    
    var isPlaying : Bool = false
    var subViewsArray : [UIView] = [UIView]()
    var progressViewsArray : [UIView] = [UIView]()
    var progressViewsConstraintsArray : [NSLayoutConstraint] = [NSLayoutConstraint]()
    var ButtonsArray: [UIButton] = [UIButton]()
    var i: CGFloat = 1.0
    
    var ProButton : UIButton = UIButton()
    var SoundButton : UIButton = UIButton()
    var InfoButton : UIButton = UIButton()
    
    var InfoButtonsArray : [UIButton] = [UIButton]()

    var disableProgressTimer = Timer()
    @IBOutlet weak var bannerView: GADBannerView!
    var C_Values : [Int : CGFloat] = [2 : 98, 3: 188, 4: 278, 5: 353, 6:428, 7: 503, 8: 573, 9: 643, 10: 713]
    
    @IBOutlet weak var scroll: UIScrollView!
    @IBOutlet weak var ScrollView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scroll.delegate = self
        initButtonViews(n: 10)
        initInfoButtons()
        
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
        
        ProButton = UIButton(frame: CGRect(x: 0 , y: 0, width: 40.0, height: 40.0))
        ProButton.center.x = UIScreen.main.bounds.width/2
        ProButton.center.y = TitleLabel.center.y + TitleLabel.frame.height + 15
        ProButton.setImage(UIImage(named: "pro2.png"), for: .normal)
        
        SoundButton = UIButton(frame: CGRect(x: 0 , y: 0, width: 40.0, height: 40.0))
        SoundButton.center.x = ProButton.center.x + 70
        SoundButton.center.y = TitleLabel.center.y + TitleLabel.frame.height + 15
        SoundButton.setImage(UIImage(named: "soundOn.png"), for: .normal)
        
        InfoButton = UIButton(frame: CGRect(x: 0 , y: 0, width: 40.0, height: 40.0))
        InfoButton.center.x = ProButton.center.x - 70
        InfoButton.center.y = TitleLabel.center.y + TitleLabel.frame.height + 15
        InfoButton.setImage(UIImage(named: "info.png"), for: .normal)
        
        view.addSubview(ProButton)
        view.addSubview(SoundButton)
        view.addSubview(InfoButton)
        
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
        
        if ButtonsArray[Int(i)-1].tag != PlayingTag{
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
        disableProgressTimer.invalidate()
        massage.stop()
        massage = Massage(mode: sender!.tag)
        
        
        print(progressViewsConstraintsArray[sender!.tag].constant)
        progressViewsArray[PlayingTag].layer.removeAllAnimations()
        if isPlaying{
            //Stops playing
            if PlayingTag == sender!.tag{
                progressViewsConstraintsArray[sender!.tag].constant = -progressViewsArray[sender!.tag].frame.width
                view.layoutIfNeeded()
            
                isPlaying = false
            }else{
                progressViewsConstraintsArray[PlayingTag].constant = -progressViewsArray[PlayingTag].frame.width
                view.layoutIfNeeded()
                progressViewsConstraintsArray[sender!.tag].constant = 0//-progressViewsArray[sender!.tag].frame.width
                massage.play()
                UIView.animate(withDuration: massage.duration, animations: {
                    print("start")
                    self.view.layoutIfNeeded()
                })
                disableProgressTimer = Timer.scheduledTimer(withTimeInterval: massage.duration, repeats: false, block: { _ in
                    self.progressViewsConstraintsArray[sender!.tag].constant = -self.progressViewsArray[sender!.tag].frame.width
                    self.view.layoutIfNeeded()
                    self.isPlaying = false
                })
                 isPlaying = true
            }
        }else{
             isPlaying = true
            progressViewsConstraintsArray[sender!.tag].constant = 0// -progressViewsArray[sender!.tag].frame.width
            massage.play()
            UIView.animate(withDuration: massage.duration, animations: {
                self.view.layoutIfNeeded()
                print("start")
                print(self.progressViewsConstraintsArray[sender!.tag].constant)
            })
            disableProgressTimer = Timer.scheduledTimer(withTimeInterval: massage.duration, repeats: false, block: { _ in
                self.progressViewsConstraintsArray[sender!.tag].constant = -self.progressViewsArray[sender!.tag].frame.width
                self.view.layoutIfNeeded()
                self.isPlaying = false
            })
            
        }
        
        
        PlayingTag = sender!.tag
   
    
       
     
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
