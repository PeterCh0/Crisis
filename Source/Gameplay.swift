//
//  Gameplay.swift
//  Mastery
//
//  Created by Peter Cho on 10/22/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

import UIKit

enum HeroState {
    case Moving
    case Idle
}

enum GameState {
    case Playing
    case Paused
}

class Gameplay: CCScene, CCPhysicsCollisionDelegate {
    //MARK: misc vars
    weak var gamePhysicsNode: CCPhysicsNode!
    var attackNode: AttackNode?
    var gameState: GameState = .Playing
    var touchDidMove: Bool = false    //flag to determine if touch is a tap or drag
    
    //MARK: UI vars
    weak var retryButton: CCButton!
    
    //MARK: Weapon vars
    var basicBullet: BasicBullet?
    var basicBullets: [BasicBullet] = []
    var bulletVelocity: CGPoint = CGPoint(x: 0, y: BasicBullet.bulletSpeed)
    
    //Mark: hero vars
    var hero: Hero?
    var heroState: HeroState = .Idle
    var maxHeroVelocity: CGFloat = 0
    
    //Mark: movement vars
    var cursorReference: CGPoint?
    var maxCursorDistance: CGFloat = CCDirector.sharedDirector().viewSize().height * 0.07
    
 
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//MARK: GamePlay methods
    
    
    func didLoadFromCCB() {
        gamePhysicsNode.collisionDelegate = self
        userInteractionEnabled = true
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("fireBasicBullet:"), name:"fireBasicBullet", object: nil)

        
        //initial hero spawn
        let heroStartingPosition = CGPoint(x: CCDirector.sharedDirector().viewSize().width / 2, y: CCDirector.sharedDirector().viewSize().height / 2)
        hero = CCBReader.load("Hero") as? Hero
        hero!.position = heroStartingPosition
        maxHeroVelocity = hero!.maxVelocity
        gamePhysicsNode.addChild(hero)
        attackNode = CCBReader.load("AttackNode") as? AttackNode
        attackNode!.position = CGPoint(x: CCDirector.sharedDirector().viewSize().width * 0.85, y: CCDirector.sharedDirector().viewSize().height * 0.17)
        self.addChild(attackNode)
    }
    
    
    override func update(delta: CCTime) {
//        println(hero!.rotation)
//        println(hero!.testGun.rotation)
    }
    
    func pause() {
        gameState = .Paused
        hero!.stopAllActions()
    }
    
    func gameOver() {
        //pull up game over screen, retry, share, score, menu, etc
        //death animations etc
        retryButton.visible = true

        println("game over!")
        retryButton.visible = true
    }
    
    override func onExit() {
        super.onExit()
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
  
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//MARK: Touch Handling
    
    override func touchBegan(touch: CCTouch!, withEvent event: CCTouchEvent!) {

        //setting the reference point for hero movement
        if heroState == .Idle && gameState == .Playing {
            cursorReference = touch.locationInWorld()
            hero!.physicsBody.type = CCPhysicsBodyType.Dynamic
        }
    }
    
    override func touchMoved(touch: CCTouch!, withEvent event: CCTouchEvent!) {
        if gameState == .Playing {
            heroState = .Moving
            touchDidMove = true

            //if touch is moved, player wants to move.
            //calc position relative to ref point from touchBegan --> compare with the max distance --> scale velocity accordingly in the direction of drag
            let moveReferencePoint = touch.locationInWorld()
            let deltaX = moveReferencePoint.x - cursorReference!.x
            let deltaY = moveReferencePoint.y - cursorReference!.y
            //pythagorean thm to calculate distance from cursorReference to moveReferencePoint
            let cursorDistance = pow(pow(deltaX, 2) + pow(deltaY, 2), (1 / 2))
            
            //if distance is greater than the max distance, just use the maximum velocity to cut off scaling
            if cursorDistance >= maxCursorDistance {
                //unit vector in the direction of drag multiplied by max velocity
                let maxVelocity = CGPoint(x: deltaX / cursorDistance * maxHeroVelocity, y: deltaY / cursorDistance * maxHeroVelocity)
                hero!.physicsBody.velocity = maxVelocity
            } else {
                //calc ratio of drag distance to max distance and scale the max velocity down accordingly
                let velocityRatio = cursorDistance / maxCursorDistance
                let moveVelocity = CGPoint(x: deltaX / cursorDistance * maxHeroVelocity * velocityRatio, y: deltaY / cursorDistance * maxHeroVelocity * velocityRatio)
                hero!.physicsBody.velocity = moveVelocity
            }
        
            /////////////////////////////////////////////////////////////////////////////////////////////////////////////////
            //MARK: handling hero rotation

            
            let heroRotationAngle = Float(atan(abs(deltaX) / abs(deltaY))) * Float(180 / M_PI)

            if deltaX > 0 && deltaY >= 0 {
                hero!.testGun.rotation = heroRotationAngle
            } else if deltaX >= 0 && deltaY < 0 {
                hero!.testGun.rotation = 180 - heroRotationAngle
            } else if deltaX < 0 && deltaY <= 0 {
                hero!.testGun.rotation = 180 + heroRotationAngle
            } else if deltaX <= 0 && deltaY > 0 {
                hero!.testGun.rotation = 360 - heroRotationAngle
            } else {
                return
            }
            
            //handling hero rotation
            /////////////////////////////////////////////////////////////////////////////////////////////////////////////////

            bulletVelocity = CGPoint(x: deltaX / cursorDistance * BasicBullet.bulletSpeed, y: deltaY / cursorDistance * BasicBullet.bulletSpeed)
        }
    }
    
    override func touchEnded(touch: CCTouch!, withEvent event: CCTouchEvent!) {
        if touchDidMove == false {
            //there is a flag for if the touch moved or not, but don't know what to do with it yet
        } else {
            //cursorReference = nil
            heroState = .Idle
            hero!.physicsBody.type = CCPhysicsBodyType.Static
            //reset the drag flag
            touchDidMove = false
        }
    }
    
//Touch Handling
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//MARK: Collision Handling
    
    func ccPhysicsCollisionPostSolve(pair: CCPhysicsCollisionPair!, hero: Hero!, border: CCNode!) {
        gameOver()
        println("you hit a wall!")
        pause()

    }
    
    func ccPhysicsCollisionPostSolve(pair: CCPhysicsCollisionPair!, bullet: BasicBullet!, border: CCNode!) {
        bullet.removeFromParent()
    }

//Collision handling
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//MARK: Weapons
    
    func fireBasicBullet(notification: NSNotification) {
        if gameState == .Playing {
            basicBullet = CCBReader.load("BasicBullet") as? BasicBullet
            basicBullet!.position = hero!.position
            gamePhysicsNode.addChild(basicBullet)
            basicBullet!.physicsBody.velocity = bulletVelocity
            println("attack")
        }
    }

//Weapons
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//MARK: UI implementation
    
    func retry() {
        let reloadScene = CCBReader.loadAsScene("Gameplay")
        CCDirector.sharedDirector().presentScene(reloadScene)
    }

//UI implementation
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

}
