//
//  Hero.swift
//  Mastery
//
//  Created by Peter Cho on 10/22/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

import UIKit

class Hero: CCNode {
    
    weak var testGun: CCNode!
    
    var maxVelocity: CGFloat = 200.0
    
    func didLoadFromCCB() {
        testGun.rotation = 0
    }
    
    func attack() {
        println("attack!!")
    }
   
}
