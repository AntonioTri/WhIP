//
//  Pesce.swift
//  WhipDemoWatch Watch App
//
//  Created by Antonio Tridente on 30/03/24.
//

import Foundation





class Pesce{
    
    var type: Int = -1
    var rarity: Int = -1
    
    var maxIteration: Int = -1
    var heartbitRate: Double = -1
    var minNearness: Int = -1
    var eatingVibration: Int = -1
    var eatingTime: Int = -1
    var movementSpeed: Int = -1
    var minStrenght: Int = -1
    var maxStrenght: Int = -1
    var decreaseRopeLight: Int = -1
    var decreaseRopeHeavy: Int = -1
    var takeRopeLight: Int = -1
    var takeRopeMedium: Int = -1
    var takeRopeHeavy: Int = -1
    var loseRopeLight: Int = -1
    var loseRopeMedium: Int = -1
    var loseRopeHigh: Int = -1
    var fishingRodBreakingSpeed: Int = -1
    
    init(type: Int, rarity: Int){
        
        self.type = type
        self.rarity = rarity
        getMovementSpeed()
        getEatingTime()
        getMaxStrenght()
        getMinStrenght()
        getMinNearness()
        getHeartbitRate()
        getMaxIteration()
        getEatingVibration()
        getLoseRope()
        getTakeRope()
        getDecreaseRopeHeavy()
        getDecreaseRopeLight()
        getBrakeFishingRodSpeed()
        
    }

    
    // funzione che setta il valore di iterazioni massime
    // basandosi sulla rarità
    private func getMaxIteration(){
        
        switch rarity {
            
        case 0:
            self.maxIteration = 20
        case 1:
            self.maxIteration = 18
        case 2:
            self.maxIteration = 14
        case 3:
            self.maxIteration = 10
            
        default:
            self.maxIteration = 15
            
        }
    }
    
    // Funzione che definisce la velocità dei battiti
    private func getHeartbitRate(){
        
        switch type {
        case 0:
            self.heartbitRate = 0.18
            
        case 1:
            self.heartbitRate = 0.2
        case 2:
            self.heartbitRate = 0.22
        case 3:
            self.heartbitRate = 0.24
        case 4:
            self.heartbitRate = 0.26
        case 5:
            self.heartbitRate = 0.3
        case 6:
            self.heartbitRate = 0.32
        case 7:
            self.heartbitRate = 0.34
        case 8:
            self.heartbitRate = 0.35
        case 9:
            self.heartbitRate = 0.36
            
        default:
            self.heartbitRate = 0.3
            
        }
    }
    
    func timeBetweenHeartbit(nearness: Int) -> Double {
        
        switch nearness {
            
        case 1:
            print(Double(movementSpeed) / 5.0)
            return Double(movementSpeed) / 5.0
        case 2:
            print(Double(movementSpeed) / 4.0)
            return Double(movementSpeed) / 4.0
        case 3:
            print(Double(movementSpeed) / 3.0)
            return Double(movementSpeed) / 3.0
        case 4:
            print(Double(movementSpeed) / 2.0)
            return Double(movementSpeed) / 2.0
        case 5:
            print(Double(movementSpeed))
            return Double(movementSpeed)
        default:
            print(Double(movementSpeed) / 3.0)
            return Double(movementSpeed) / 3.0
            
        }
        
    }
    
    private func getMinNearness(){
        
        switch rarity {
            
        case 0:
            self.minNearness = 3
        case 1:
            self.minNearness = 3
        case 2:
            self.minNearness = 2
        case 3:
            self.minNearness = 1
            
        default:
            self.minNearness = 2
            
        }
    }
    
    private func getEatingVibration(){
        
        switch rarity {
            
        case 0:
            self.eatingVibration = 180
        case 1:
            self.eatingVibration = 120
        case 2:
            self.eatingVibration = 90
        case 3:
            self.eatingVibration = 50
            
        default:
            self.eatingVibration = 120
            
        }
        
    }
    
    private func getEatingTime(){
        
        switch rarity {
            
        case 0:
            self.eatingTime = 18
        case 1:
            self.eatingTime = 12
        case 2:
            self.eatingTime = 9
        case 3:
            self.eatingTime = 5
            
        default:
            self.eatingTime = 12
            
        }
        
    }
    
    private func getMovementSpeed(){
        
        switch type {
        case 0, 1:
            self.movementSpeed = 2
        case 2, 3, 4:
            self.movementSpeed = 3
        case 5, 6, 7, 8:
            self.movementSpeed = 4
        case 9:
            self.movementSpeed = 5
        default:
            self.movementSpeed = 5
        
        }
        
    }
    
    private func getMinStrenght(){
        
        switch rarity {
            
        case 0:
            self.minStrenght = 0
        case 1:
            self.minStrenght = 1
        case 2:
            self.minStrenght = 2
        case 3:
            self.minStrenght = 2
            
        default:
            self.minStrenght = 0
            
        }
    }
    
    private func getMaxStrenght(){
        
        if rarity < 2 {
            self.maxStrenght = 4
        } else if rarity >= 2{
            self.maxStrenght = 5
        }
        
    }
    
    private func getDecreaseRopeLight(){
        
        if type < 3 {
            self.decreaseRopeLight = 2
        } else if type >= 3 && type < 7 {
            self.decreaseRopeLight = 3
        } else if type >= 7 && type <= 9 {
            self.decreaseRopeLight = 4
        }
        
    }
    
    private func getDecreaseRopeHeavy(){
        
        if type < 3 {
            self.decreaseRopeHeavy = 3
        } else if type >= 3 && type < 7 {
            self.decreaseRopeHeavy = 5
        } else if type >= 7 && type <= 9 {
            self.decreaseRopeHeavy = 7
        }
    }
    
    private func getTakeRope(){
        
        if type < 3 {
            
            self.takeRopeLight = 2
            self.takeRopeMedium = 4
            self.takeRopeHeavy = 6
            
        } else if type >= 3 && type < 7 {
            
            self.takeRopeLight = 3
            self.takeRopeMedium = 5
            self.takeRopeHeavy = 7
            
        } else if type >= 7 && type <= 9 {
            
            self.takeRopeLight = 4
            self.takeRopeMedium = 6
            self.takeRopeHeavy = 8
            
        }
        
        switch rarity {
            
        case 0:
            self.addModForTake(value: -2)
        case 1:
            self.addModForTake(value: -1)
        case 2:
            self.addModForTake(value: +1)
        case 3:
            self.addModForTake(value: +2)
            
        default:
            self.addModForTake(value: 0)
            
        }
        
        
        
    }
    
    
    private func getLoseRope(){
        
        if type < 3 {
            
            self.loseRopeHigh = 10
            self.loseRopeMedium = 6
            self.loseRopeLight = 3
            
        } else if type >= 3 && type < 7 {
            
            self.loseRopeHigh = 8
            self.loseRopeMedium = 5
            self.loseRopeLight = 2
            
        } else if type >= 7 && type <= 9 {
            
            self.loseRopeHigh = 6
            self.loseRopeMedium = 3
            self.loseRopeLight = 1
            
        }
        
        switch rarity {
            
        case 0:
            self.addModForLose(value: +2)
        case 1:
            self.addModForLose(value: +1)
        case 2:
            self.addModForLose(value: 0)
        case 3:
            self.addModForLose(value: -1)
            
        default:
            self.addModForLose(value: 0)
            
        }
        
    }
    
    
    private func getBrakeFishingRodSpeed(){
       
        if type < 3 {
            
            self.fishingRodBreakingSpeed = 1
            
        } else if type >= 3 && type < 7 {
            
            self.fishingRodBreakingSpeed = 2
            
        } else if type >= 7 && type <= 9 {
            
            self.fishingRodBreakingSpeed = 3
            
        }
        
        switch rarity {
            
        case 0:
            self.fishingRodBreakingSpeed -= 1
        case 1:
            self.fishingRodBreakingSpeed += 0
        case 2:
            self.fishingRodBreakingSpeed += 0
        case 3:
            self.fishingRodBreakingSpeed += 1
            
        default:
            self.fishingRodBreakingSpeed += 0
            
        }
    }
    
    
    private func addModForTake(value: Int){
        
        self.takeRopeLight += value
        self.takeRopeMedium += value
        self.takeRopeHeavy += value
        
    }
    
    private func addModForLose(value: Int){
        
        self.loseRopeHigh += value
        self.loseRopeMedium += value
        self.loseRopeLight += value
        
    }

}
