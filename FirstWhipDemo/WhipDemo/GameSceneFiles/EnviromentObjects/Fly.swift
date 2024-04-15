//
//  BreadBait.swift
//  WhipDemo
//
//  Created by Antonio Tridente on 14/04/24.
//

import Foundation
import SpriteKit

class Fly {
    
    let scene: SKScriptIphone
    let savingCenter: SavingsCenter
    var flyVideo = SKVideoNode()
    var flyNode = SKSpriteNode()
    var tutorialNode = SKSpriteNode()
    var scriptedAction = SKAction()
    var sound = SKAction()
    var flyGoAway = false
    var canSpawnFly = false
    var stopSpawningFlyes = false
    var flyIsSpawned = false
    
    let url1 = Bundle.main.url(forResource: "arrivingfly", withExtension: "mov")
    let url2 = Bundle.main.url(forResource: "flyingAroundFly", withExtension: "mov")
    let url3 = Bundle.main.url(forResource: "flyGoingAway", withExtension: "mov")
    
    init(scene: SKScriptIphone, savingCenter: SavingsCenter) {
        self.scene = scene
        self.savingCenter = savingCenter
        self.inizialize()
        
    }
    
    
    func startSpawningFlyes(){
        
        var timeToNextFly = Double.random(in: 5...7)
        self.canSpawnFly = true
        
        Timer.scheduledTimer(withTimeInterval: timeToNextFly, repeats: true){ timer in
            
            if self.stopSpawningFlyes {
                self.stopSpawningFlyes = false
                timer.invalidate()
            }
            
            if self.canSpawnFly && !self.stopSpawningFlyes {
                self.canSpawnFly = false
                timeToNextFly = Double.random(in: 13...15)
                self.spawnFly()
            }
        }
    }
    
    
    private func spawnFly(){
        
        // Viene mostrato un tutorial solo una volta
        self.showTutorial()
        
        print("Faccio partire il video")
        self.flyIsSpawned = true
        self.flyNode.removeFromParent()
        self.scene.addChild(self.flyNode)
        self.flyNode.run(self.scriptedAction)
        
    }
    
    private func inizialize(){
        
        self.sound = SKAction.repeatForever(SKAction.playSoundFileNamed("flySound", waitForCompletion: true))
        self.flyNode = self.scene.childNode(withName: "flyNode") as! SKSpriteNode
        self.flyNode.alpha = 0
        self.flyNode.removeFromParent()
        
        self.scriptedAction = SKAction.run {
            self.assignVideo(url: self.chooseStartingAnimation())
            self.flyVideo.play()
            self.flyVideo.run(self.sound)
            Timer.scheduledTimer(withTimeInterval: 1.8, repeats: false){ _ in
                self.assignSecondVideo()
            }
        }
    }
    
    private func chooseStartingAnimation() -> URL {
        let url = Bundle.main.url(forResource: "arrivingfly-\(Int.random(in: 1...3))", withExtension: "mov")
        return url!
    }
    
    private func assignSecondVideo(){
        
        self.assignVideo(url: url2!)
        
        Timer.scheduledTimer(withTimeInterval: 1.3, repeats: false){ timer in
            
            if !self.flyGoAway {
                self.assignSecondVideo()
            } else {
                print("You want the fly to go away")
                self.assignVideo(url: self.url3!)
                self.removeFly()
                timer.invalidate()
            }
        }
    }
    
    private func assignVideo(url: URL){
            
        self.flyVideo.removeFromParent()
        self.flyVideo = SKVideoNode(url: url)
        self.flyVideo.size = CGSize(width: 1680, height: 600)
        self.scene.addChild(self.flyVideo)
        self.flyVideo.position = CGPoint(x: 0, y: 330)
        self.flyVideo.play()
        
    }
    
    private func removeFly(){
        
        self.flyVideo.removeAllActions()
        Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false){ _ in
            
            self.flyVideo.removeFromParent()
            self.flyIsSpawned = false
            self.flyGoAway = false
            self.canSpawnFly = true
        }
        
    }
    
    // Questa funzione viene eseguita solo una volta quando compare la prima mosca
    private func showTutorial(){
        
        if !savingCenter.getSavedBool(key: savingCenter.FLY_TUTORIAL) {
            savingCenter.saveBool(dataToSave: true, key: savingCenter.FLY_TUTORIAL)
            print("Showing fly tutorial")
            
            self.tutorialNode = SKSpriteNode(imageNamed: "flyTutorial")
            self.tutorialNode.size = CGSize(width: 370, height: 207)
            self.tutorialNode.zPosition = 50
            self.tutorialNode.alpha = 0
            
            self.scene.addChild(self.tutorialNode)
            self.tutorialNode.position = CGPoint(x: -453, y: 530)
            self.tutorialNode.run(scene.fadeIn)
            
            Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true){ timer in
                    
                if self.flyGoAway {
                    self.tutorialNode.run(SKAction.sequence([self.scene.fadeOut, SKAction.run {
                        self.tutorialNode.removeFromParent()
                    }]))
                    
                    timer.invalidate()
                }
            }
        }
    }
    
    func getFlyIsSpawned() -> Bool {
        return self.flyIsSpawned
    }
    
    func setFlyGoAway(){
        self.flyGoAway = true
    }
    
    func stopSpawningMoreFlyes(){
        self.stopSpawningFlyes = true
        self.canSpawnFly = false
        setFlyGoAway()
    }
    
    
}
