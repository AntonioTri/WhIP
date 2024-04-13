//
//  File.swift
//  WhipDemo
//
//  Created by Antonio Tridente on 03/04/24.
//

import Foundation
import SpriteKit

class BackGround{
    
    var scene: SKScriptIphone
    var backGroundNode = SKSpriteNode()
    
    init(scene: SKScriptIphone) {
        self.scene = scene
        self.initialize()
    }
    
    // Sulla base dell'ora corrente viene scelto il backGround adatto
    private func initialize(){
    
        switch findHour() {
        case 0:
            setBackGround(number: 0)
        case 1:
            setBackGround(number: 0)
        case 2:
            setBackGround(number: 0)
        default:
            print("Errore nella generazione dell'ora")
        }

    }

    // Questa funzione imposta il backGround sulla base della fascia oraria scelta
    private func setBackGround(number: Int){
        
        //Sprite backGround in base all'ora
        let bg1 = SKTexture(imageNamed: String("sfondo\(number)0"))
        let bg2 = SKTexture(imageNamed: String("sfondo\(number)1"))
        let bg3 = SKTexture(imageNamed: String("sfondo\(number)2"))
        let bg4 = SKTexture(imageNamed: String("sfondo\(number)3"))
        let bg5 = SKTexture(imageNamed: String("sfondo\(number)4"))
        let bg6 = SKTexture(imageNamed: String("sfondo\(number)5"))
        
        // Si crea l'animazione infinita per il backGround
        let backgroundTextures = [bg1, bg2, bg3, bg4, bg5, bg6]
        let backGroundAnimation = SKAction.animate(with: backgroundTextures, timePerFrame: 0.25)
        let repeatActionBG = SKAction.repeatForever(backGroundAnimation)
        
        // Creiamo i suoni
        let backGroundSound = SKAction.playSoundFileNamed("ambience", waitForCompletion: true)
        let backGroundAmbiance = SKAction.repeatForever(backGroundSound)
        
        // Aggiungiamo le caratteristiche di base ed aggiungiamo il nodo alla scena
        backGroundNode = SKSpriteNode(texture: bg1)
        backGroundNode.position = CGPoint(x: 0, y: scene.size.height / 2)
        backGroundNode.size = CGSize(width: 1634, height: 750)
        backGroundNode.zPosition = -100
        backGroundNode.run(repeatActionBG)
        backGroundNode.run(backGroundAmbiance)
        scene.addChild(backGroundNode)
    }
    
    // Questa funzione serve a ritornare il valore normalizzato della corrente fascia oraria
    private func findHour() -> Int {
        
        let calendar = Calendar.current
        var hour = calendar.component(.hour, from: Date())
        
        if hour >= 9 && hour < 15 {
            hour = 0
        } else if hour >= 15 && hour < 21 {
            hour = 1
        } else if (hour >= 21 && hour <= 24) || (hour > 0 && hour < 9) {
            hour = 2
        }
        
        return hour
    }
    
    
}
