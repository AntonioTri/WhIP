//
//  BlinkingRedSignal.swift
//  WhIP Watch App
//
//  Created by lucadm on 17/04/24.
//

import Foundation
import SpriteKit
import WatchKit

class BlinkingRedSignal {
    
    let scene: GameSceneScript!
    var redSignal = SKSpriteNode()
    let fadeIn = SKAction.fadeAlpha(to: 1.0, duration: 0.3)
    let fadeOut = SKAction.fadeAlpha(to: 0, duration: 0.2)
    var blinking = SKAction()
    
    init(scene: GameSceneScript!) {
        self.scene = scene
        self.redSignal = SKSpriteNode(imageNamed: "Warning")
        self.createAnimations()
        self.redSignal.removeFromParent()
    }
    
    // Funzione che inizia a far pulsare il segnale di pericolo rottura lenza
    func startBlinking(){
        self.scene.addChild(self.redSignal)
        self.redSignal.run(blinking)
    }
    
    // Segnale che fa smettere al nodo di pulsare
    func stopBlinking(){
        
        let removeAction = SKAction.run {
            self.redSignal.removeFromParent()
        }
        self.redSignal.removeAllActions()
        self.redSignal.run(SKAction.sequence([SKAction.fadeAlpha(to: 0, duration: 0.2), removeAction]))
        
    }
    
    // funzione che crea delle semplici animazioni di blinking
    private func createAnimations(){
        let sound = SKAction.run {
            WKInterfaceDevice.current().play(.directionDown)
        }
        let sequence = SKAction.sequence([fadeIn, sound, fadeOut])
        self.blinking = SKAction.repeatForever(sequence)
        self.redSignal.position = CGPoint(x: -40, y: 40)
        self.redSignal.size = CGSize(width: 30, height: 30)
        self.redSignal.zPosition = 50
        
    }

}


