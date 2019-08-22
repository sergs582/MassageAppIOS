//
//  Massage.swift
//  MassageAppIOS
//
//  Created by Сергей on 07/08/2019.
//  Copyright © 2019 Сергей. All rights reserved.
//

import Foundation
import AVFoundation
import AudioToolbox
import UIKit

class Massage {
    
    enum Mode : Int {
        case HandVibroPillow
        case ShockTherapy
        case QuickRelax
        case LightImpulse
        case HeartbeatingImpulse
        case PocketEarthquake
        case StarWarsImerialMarch
        case ImpulsiveWaves
        case TopSpeed
        case Random
    }
    
    
    enum Feedback {
        case Heavy
        case Light
        case Medium
        case Vibro
    }
    
    
    
    var duration : Double = 0
    var rep: Int = 0
    var mode : Mode? = nil
    var i = 0
    var timer = Timer()
    
   
    private var currentMassage : [Feedback] = [Feedback]()
    private let MassagesArray : [[Feedback]] = [[.Vibro, .Heavy, .Heavy, .Vibro, .Vibro, .Heavy, .Light,
                                                 .Heavy, .Heavy, .Heavy, .Medium, .Medium, .Vibro, .Heavy, .Light,
                                                 .Heavy, .Heavy, .Heavy, .Medium, .Medium, .Vibro, .Heavy, .Light,
                                                 .Heavy, .Heavy, .Heavy, .Medium, .Medium, .Vibro, .Heavy, .Light,
                                                 .Heavy, .Heavy, .Heavy, .Medium, .Medium, .Vibro, .Heavy, .Light],
                                                [.Vibro, .Vibro, .Vibro, .Medium, .Medium, .Vibro, .Heavy, .Light,
                                                 .Heavy, .Heavy, .Heavy, .Medium, .Medium, .Vibro, .Heavy, .Light,
                                                 .Heavy, .Heavy, .Heavy, .Medium, .Medium, .Vibro, .Heavy, .Light,
                                                 .Heavy, .Heavy, .Heavy, .Medium, .Medium, .Vibro, .Heavy, .Light,
                                                 .Heavy, .Heavy, .Heavy, .Medium, .Medium, .Vibro, .Heavy, .Light],
                                                [.Heavy, .Heavy, .Heavy, .Medium, .Medium, .Vibro, .Heavy, .Light,
                                                 .Heavy, .Heavy, .Heavy, .Medium, .Medium, .Vibro, .Heavy, .Light,
                                                 .Heavy, .Heavy, .Heavy, .Medium, .Medium, .Vibro, .Heavy, .Light,
                                                 .Heavy, .Heavy, .Heavy, .Medium, .Medium, .Vibro, .Heavy, .Light,
                                                 .Heavy, .Heavy, .Heavy, .Medium, .Medium, .Vibro, .Heavy, .Light],
                                                [.Heavy, .Heavy, .Heavy, .Medium, .Medium, .Vibro, .Heavy, .Light,
                                                 .Heavy, .Heavy, .Heavy, .Medium, .Medium, .Vibro, .Heavy, .Light,
                                                 .Heavy, .Heavy, .Heavy, .Medium, .Medium, .Vibro, .Heavy, .Light,
                                                 .Heavy, .Heavy, .Heavy, .Medium, .Medium, .Vibro, .Heavy, .Light,
                                                 .Heavy, .Heavy, .Heavy, .Medium, .Medium, .Vibro, .Heavy, .Light],
                                                [.Heavy, .Heavy, .Heavy, .Medium, .Medium, .Vibro, .Heavy, .Light,
                                                 .Heavy, .Heavy, .Heavy, .Medium, .Medium, .Vibro, .Heavy, .Light,
                                                 .Heavy, .Heavy, .Heavy, .Medium, .Medium, .Vibro, .Heavy, .Light,
                                                 .Heavy, .Heavy, .Heavy, .Medium, .Medium, .Vibro, .Heavy, .Light,
                                                 .Heavy, .Heavy, .Heavy, .Medium, .Medium, .Vibro, .Heavy, .Light],
                                                [.Heavy, .Heavy, .Heavy, .Medium, .Medium, .Vibro, .Heavy, .Light,
                                                 .Heavy, .Heavy, .Heavy, .Medium, .Medium, .Vibro, .Heavy, .Light,
                                                 .Heavy, .Heavy, .Heavy, .Medium, .Medium, .Vibro, .Heavy, .Light,
                                                 .Heavy, .Heavy, .Heavy, .Medium, .Medium, .Vibro, .Heavy, .Light,
                                                 .Heavy, .Heavy, .Heavy, .Medium, .Medium, .Vibro, .Heavy, .Light],
                                                [.Heavy, .Heavy, .Vibro, .Heavy, .Heavy, .Heavy, .Heavy, .Heavy,
                                                 .Vibro, .Heavy, .Heavy, .Vibro, .Heavy, .Heavy, .Heavy, .Heavy, .Heavy,
                                                 .Vibro,.Heavy, .Heavy, .Vibro, .Heavy, .Heavy, .Heavy, .Heavy, .Heavy,
                                                 .Vibro,.Heavy, .Heavy, .Vibro, .Heavy, .Heavy, .Heavy, .Heavy, .Heavy,
                                                 .Vibro,.Heavy, .Heavy, .Vibro, .Heavy, .Heavy, .Heavy, .Heavy, .Heavy,
                                                 .Vibro,.Heavy, .Heavy, .Vibro, .Heavy, .Heavy, .Heavy, .Heavy, .Heavy,
                                                 .Vibro],
                                                [.Heavy, .Heavy, .Heavy, .Medium, .Medium, .Vibro, .Heavy, .Light,
                                                 .Heavy, .Heavy, .Heavy, .Medium, .Medium, .Vibro, .Heavy, .Light,
                                                 .Heavy, .Heavy, .Heavy, .Medium, .Medium, .Vibro, .Heavy, .Light,
                                                 .Heavy, .Heavy, .Heavy, .Medium, .Medium, .Vibro, .Heavy, .Light,
                                                 .Heavy, .Heavy, .Heavy, .Medium, .Medium, .Vibro, .Heavy, .Light],
                                                [.Heavy, .Heavy, .Heavy, .Medium, .Medium, .Vibro, .Heavy, .Light,
                                                 .Heavy, .Heavy, .Heavy, .Medium, .Medium, .Vibro, .Heavy, .Light,
                                                 .Heavy, .Heavy, .Heavy, .Medium, .Medium, .Vibro, .Heavy, .Light,
                                                 .Heavy, .Heavy, .Heavy, .Medium, .Medium, .Vibro, .Heavy, .Light,
                                                 .Heavy, .Heavy, .Heavy, .Medium, .Medium, .Vibro, .Heavy, .Light]]
    
    let heavyImpactGenerator = UIImpactFeedbackGenerator(style: .heavy)
    let lightImpactGenerator = UIImpactFeedbackGenerator(style: .light)
    let mediumImpactGenerator = UIImpactFeedbackGenerator(style: .medium)
    var vibro : Void {return AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)}
    
    
    
    init(mode: Int){
        print(mode)
        self.mode = Mode.init(rawValue: mode)!
    }
    init(){
        self.mode = nil
    }
    
    
    func play(){
        timer.invalidate()
        
        
        let TimeInterval = 0.3
        
        if mode!.rawValue < 9{
            currentMassage = MassagesArray[mode!.rawValue]
        }else{
            currentMassage = MassagesArray.randomElement()!
        }
        
        duration = TimeInterval * Double(currentMassage.count + 1)
        print(duration)
        timer = Timer(timeInterval: TimeInterval, target: self, selector: #selector(plaay), userInfo: nil, repeats: true)
        RunLoop.main.add(timer, forMode: .common)

    }
  
    func stop(){
        print("stoped")
        timer.invalidate()
    }
    
    @objc func plaay(){
        
        if i < currentMassage.count{
        switch  currentMassage[i] {
        case .Heavy:
            heavyImpactGenerator.prepare()
            heavyImpactGenerator.impactOccurred()
        case .Light:
            lightImpactGenerator.prepare()
            lightImpactGenerator.impactOccurred()
        case .Medium:
            mediumImpactGenerator.prepare()
            mediumImpactGenerator.impactOccurred()
        case .Vibro:
            vibro
        }
            i += 1
        }else{
            i = 0
            timer.invalidate()
        }
        
//        print("!!!!!!!!!!!!!!!!!")
        
    }
    
   
    
    
}
