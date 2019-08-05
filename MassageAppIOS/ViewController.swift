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

class ViewController: UIViewController, UIScrollViewDelegate {
    
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
    
    var isPlayingTag : Int = 0
    
    var subViewsArray : [UIView] = [UIView]()
    var progressViewsArray : [UIView] = [UIView]()
    var progressViewsConstraintsArray : [NSLayoutConstraint] = [NSLayoutConstraint]()
    var ButtonsArray: [UIButton] = [UIButton]()
    var i: CGFloat = 1.0
    
    var C_Values : [Int : CGFloat] = [2 : 98, 3: 188, 4: 278, 5: 353, 6:428, 7: 503, 8: 573, 9: 643, 10: 713]
    
    @IBOutlet weak var scroll: UIScrollView!
    @IBOutlet weak var ScrollView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scroll.delegate = self
        initButtonViews(n: 10)
       
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
 
        for subView in subViewsArray{
            changeButtonView(subView, ScrollView: scrollView)
        }
        lastContentOffset = scrollView.contentOffset.y
        
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
        
        if ButtonsArray[Int(i)-1].tag != isPlayingTag{
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
       isPlayingTag = sender!.tag
       
        self.progressViewsConstraintsArray[sender!.tag].constant = 0
       UIView.animate(withDuration: 10, animations: {
//        self.progressViewsArray[sender!.tag].frame = CGRect(x: 0, y: 0, width: self.subViewsArray[sender!.tag].frame.width, height: self.subViewsArray[sender!.tag].frame.height)
        //self.view.layoutIfNeeded()
        
     self.view.layoutIfNeeded()
       })
       
    }
    
    
    //
    //    @IBAction func Mode1(_ sender: Any) {
    //        amm = 10
    //        del = 0.2
    //
    //        tapticMassage(ammount: amm, delay: del, disptimer: disptime)
    //
    //       print("A")
    //      // vibroMassage(ammount: 4 , delay: 0.8, disptimer: disptime)
    //
    //
    //        // tapticMassage(ammount: 10, delay: 0.1, disptimer: disptime)
    //
    //
    //    }
    //
    //
    //
    //
    //
    //
    //    @IBAction func Mode2(_ sender: Any) {
    //
    //
    //    }
    //
    //
    //    @IBAction func Mode3(_ sender: Any) {
    //
    //
    //    }
    //    @IBAction func Mode4(_ sender: Any) {
    //    }
    //
    // // Функиция производящая тактильную отдачу amount-раз через delay- секунд
    // // disptime - задержка запуска функции
    //func tapticMassage(ammount: Int, delay: Double, disptimer: Double){
    //        DispatchQueue.main.asyncAfter(deadline: .now() + disptimer){
    //        self.n = ammount-1
    //        self.generator.prepare()
    //        self.generator.impactOccurred()
    //        self.timer = Timer.scheduledTimer(timeInterval: delay, target: self, selector: #selector(self.taptic), userInfo: nil, repeats: true)
    //        }
    //
    //    }
    //
    //
    //    @objc func taptic(){
    //        if i < n{
    //        generator.prepare()
    //        generator.impactOccurred()
    //        i+=1
    //        }else{
    //            i = 0
    //            n = 0
    //            timer.invalidate()
    //        }
    //
    //    }
    //
    //
    //    // Функиция производящая вибро отдачу amount-раз через delay- секунд
    //    // disptime - задержка запуска функции
    //    func vibroMassage(ammount: Int, delay: Double, disptimer: Double){
    //        DispatchQueue.main.asyncAfter(deadline: .now() + disptimer){
    //            self.n = ammount-1
    //            AudioServicesPlaySystemSound(4095)
    //            self.timer = Timer.scheduledTimer(timeInterval: delay, target: self, selector: #selector(self.vibro), userInfo: nil, repeats: true)
    //        }
    //
    //    }
    //
    //
    //    @objc func vibro(){
    //        if i < n{
    //             AudioServicesPlaySystemSound(4095)
    //            i+=1
    //        }else{
    //            i = 0
    //            n = 0
    //            timer.invalidate()
    //        }
    //
    //    }
    //
    //
    //
    //
}
//
extension UIButton {
    func customDesign(){
        self.layer.cornerRadius = self.frame.height/4
    }
    
    func customInit( _ parentView: UIView){
        self.frame = CGRect(x: 0, y: 0, width: parentView.frame.width, height: parentView.frame.height)
       // self.backgroundColor = .green
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
           // self.rightAnchor.constraint(equalTo: parentView.rightAnchor, constant: -parentView.frame.width).isActive = true
            self.topAnchor.constraint(equalTo: parentView.topAnchor, constant: 0).isActive = true
            self.bottomAnchor.constraint(equalTo: parentView.bottomAnchor, constant: 0).isActive = true
        
        
            self.backgroundColor = .purple
            self.layer.cornerRadius = 5
     
    }
}
