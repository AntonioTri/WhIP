//
//  CommonFishesGUI.swift
//  WhipDemo
//
//  Created by Antonio Tridente on 07/04/24.
//

import Foundation
import SpriteKit

class CommonFishesGUI {
    
    let scene: SKScriptIphone!
    let savingCenter: SavingsCenter!
    
    var GUINode = SKSpriteNode()
    var XButton = SKSpriteNode()
    var legendary1 = SKSpriteNode()
    var legendary2 = SKSpriteNode()
    var epic1 = SKSpriteNode()
    var epic2 = SKSpriteNode()
    
    // funzina tutto
    init(scene: SKScriptIphone, savingCenter: SavingsCenter) {
        self.scene = scene
        self.savingCenter = savingCenter
        self.initialize()
    }
    
    func checkXButtonPressed(touchedNode: SKSpriteNode){
        
        if touchedNode == XButton {
            XButton.run(SKAction.playSoundFileNamed("buttonClick", waitForCompletion: true))
            let removeAction = SKAction.run {
                self.GUINode.removeFromParent()
            }
            let fadeOut = SKAction.fadeAlpha(to: 0, duration: 0.4)
            self.GUINode.run(SKAction.sequence([fadeOut, removeAction]))
            self.scene.showGamingScene()
        }
    }
    
    func showUp(table: [[Int]]){
        
        // Controlla se la fasica oraria è cambiata
        checkHourChanged(table: table)
        // Controlla la flag per mostrare la gui
        if !savingCenter.getSavedBool(key: savingCenter.COMMON_FISH_SHOWED_UP) {
            savingCenter.saveBool(dataToSave: true, key: savingCenter.COMMON_FISH_SHOWED_UP)
            // Mostra la GUI
            showGUI()
        }
        
    }
    
    // Questa funzione aggiorna le scritte nella GUI
    private func updateGUI(table: [[Int]]){
        
        print("Updato la GUI")
        
        self.scene.addChild(self.GUINode)
        self.GUINode.position = CGPoint(x: 0, y: 1160)
        
        var legendText1 = SKTexture()
        var legendText2 = SKTexture()
        
        (legendText1, legendText2) = getTexts(table: table, column: 3)
        
        var epicText1 = SKTexture()
        var epicText2 = SKTexture()
        
        (epicText1, epicText2) = getTexts(table: table, column: 2)
        
        self.legendary1.texture = legendText1
        self.legendary2.texture = legendText2
        
        self.epic1.texture = epicText1
        self.epic2.texture = epicText2
        
    }
    
    // Questa funzione mostra la GUI aggiornata nello schermo
    private func showGUI(){
        
        print("Mostro la gui")
        let moveAction = SKAction.moveTo(y: 380, duration: 0.7)
        let fadeIn = scene.fadeIn
        self.GUINode.run(SKAction.group([fadeIn,moveAction]))
        
    }
    
    private func checkHourChanged(table: [[Int]]){
        
        let currentHour = self.scene.findHour()
        let savedHour = savingCenter.getSavedInteger(key: savingCenter.GUI_HOUR_SAVED)
        
        print("\(currentHour) - \(savedHour)")
        
        if savedHour != currentHour {
            savingCenter.saveInteger(dataToSave: currentHour, key: savingCenter.GUI_HOUR_SAVED)
            savingCenter.saveBool(dataToSave: false, key: savingCenter.COMMON_FISH_SHOWED_UP)
            // Aggiorna la GUI ai valori attuali
            updateGUI(table: table)
        }
        
    }
    
    
    private func getTexts(table: [[Int]], column: Int) -> (SKTexture, SKTexture){
        
        var first = 0
        var second = 0
        
        (first, second) = findFirstAndSecondMax(in: table, column: column)
        
        let firstTexture = SKTexture(imageNamed: String("fishText-\(first)"))
        let secondTexture = SKTexture(imageNamed: String("fishText-\(second)"))
        
        return (firstTexture, secondTexture)
        
    }
    
    
    private func findFirstAndSecondMax(in matrix: [[Int]], column: Int) -> (Int, Int){
        
        guard !matrix.isEmpty, column >= 0, column < matrix[0].count else {
            return (0,0) // Matrice vuota o indice di colonna non valido
        }
        
        var maxIndex = -1
        var secondMaxIndex = -1
        var maxValue = Int.min
        var secondMaxValue = Int.min
        
        for (row, rowValues) in matrix.enumerated() {
            if rowValues[column] > maxValue {
                secondMaxValue = maxValue
                secondMaxIndex = maxIndex
                maxValue = rowValues[column]
                maxIndex = row
            } else if rowValues[column] > secondMaxValue {
                secondMaxValue = rowValues[column]
                secondMaxIndex = row
            }
        }
        
        return (maxIndex, secondMaxIndex)
        
    }
    
    
    private func initialize(){
        
        GUINode = scene.childNode(withName: "commonFish") as! SKSpriteNode
        XButton = GUINode.childNode(withName: "XButton") as! SKSpriteNode
        legendary1 = GUINode.childNode(withName: "legendary1") as! SKSpriteNode
        legendary2 = GUINode.childNode(withName: "legendary2") as! SKSpriteNode
        epic1 = GUINode.childNode(withName: "epic1") as! SKSpriteNode
        epic2 = GUINode.childNode(withName: "epic2") as! SKSpriteNode
        
        GUINode.removeFromParent()
        
    }
    
    
    
    
}
