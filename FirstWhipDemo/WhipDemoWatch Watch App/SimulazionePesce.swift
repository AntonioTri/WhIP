//
//  SimulazionePesce.swift
//  Vibrations Watch App
//
//  Created by Antonio Tridente on 05/03/24.
//

import Foundation
import WatchKit
import SwiftUI

var strenghtGlobal = 0

class SimulazionePesce {
    
    
    private let fish: HapticFish = HapticFish()
    private var fishing: HapticFishing
    private let hapticFeedback: HapticFeedback = HapticFeedback()
    var viewModel: ViewModel!
    private var initialTimer: Timer = Timer()
    private var simulationTimer: Timer = Timer()
    private var nearness: Int = 0
    private var baiting: Bool = false
    private var waitObserver: Bool = false
    private var fishSpawned: Int = 0
    
    init(viewModel: ViewModel){
        
        self.viewModel = viewModel
        self.fishing = HapticFishing(viewModel: viewModel)
        
    }
    
    func simulate(type: Int, rarity: Int){
        
        self.fishSpawned = Int.random(in: 0...4)
        
        let pesce = Pesce(type: viewModel.typeSpawned, rarity: viewModel.choosedRarity)
        print("Type: \(viewModel.typeSpawned).\nRarity: \(viewModel.choosedRarity).\n")
        // Pesce.getForza() Pesce.GetTempoDiAttesa()
        
        self.initialTimer = Timer.scheduledTimer(withTimeInterval: Double.random(in: 4...10), repeats: false){ initialTimer in
            self.startSimulation(pesce: pesce)
            self.initialTimer.invalidate()
        }
    }
    
    private func startSimulation(pesce: Pesce){
        
        //si genera un numero randomico rappresentante il numero di iterazioni massime che il pesce può fare
        let iterations = Int.random(in: 5...pesce.maxIteration)
        var iterationCount = 0
        self.waitObserver = false
        
        simulationTimer = Timer.scheduledTimer(withTimeInterval: Double(pesce.movementSpeed + 1), repeats: true){ simulationTimer in
            
            // Se l'observer sta agendo viene impedito di effettuare nuove simulazioni
            if !self.waitObserver {
                
                //si genera una nuova vicinanza
                let nearness = Int.random(in: pesce.minNearness...5)
                //Si invalida la vicinanza precedente
                self.fish.invalidateTimer()
                
                // Se la nearness vale 5, il pesce sta mangiando l'esca e viene
                // eseguita la simulazione ed il codice per farlo abboccare
                if nearness == 5{
                    self.tryToFish(pesce: pesce)
                // Altrimenti in tutti gli altri casi si simula il battito cardiaco
                } else {
                    self.fish.aboccaPesce(nearness: pesce.timeBetweenHeartbit(nearness: nearness), hearthBitRate: pesce.heartbitRate)
                }                
                
                //Viene aumentato il contatore di iterazione, se questo supera le iterazioni massime
                //il timer attuale viene invalidato e viene iniziata una nuova simulazione tramite
                //segnali dalla connectivity, l'iPhone genera un nuovo pesce e la simulazione ricomincia
                iterationCount += 1
                if iterationCount > iterations {
                    self.simulationTimer.invalidate()
                    self.fish.invalidateTimer()
                    self.viewModel.sendMessage(key: "fishWentAway", value: 1)
                   
                }
            }
        }
    }
    
//    private func setNearness(caso: Int){
//        self.nearness = 5 - caso
//        self.baiting = false
//    }
    
    private func tryToFish(pesce: Pesce){
        
        self.baiting = false
        hapticFeedback.doVibration(timeInterval: 0.01, chooseVibration: 3, nroVibrazioni: pesce.eatingVibration)
        previousScroll = scroll - 1
        var contatore = 0
        
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true){ timer in
            
            if previousScroll > scroll {
                // Viene segnalato di non proseguire con le simulazioni
                self.waitObserver = true
                timer.invalidate()
                print("Pesce abbocato")
                
                self.simulationTimer.invalidate()
                self.fishing.simulaForzaPesce(pesce: pesce)
                //Si invia il segnale di avvenuta pesca
                self.viewModel.sendMessage(key: "Pesca", value: 1)
                
            }
            
            contatore += 1
            if contatore > pesce.eatingTime {
                self.waitObserver = false
                timer.invalidate()
            }
            
        }
        
    }


    
    
}


//This last class represents the fish captured who's trying to get away. It's based on the creation of a random number
//Representing the fish strenght, the time between the vibrations is managed by a switch case "casing" on the strenght variable

var condizioneVittoria = -1



class HapticFishing {
    
    var timerInterno: Timer?
    var timerEsterno: Timer?
    var observerTimer: Timer?
    var tempoIinterno = 0.0
    let hapticFeedback: HapticFeedback = HapticFeedback()
    var vittoria = 400
    var scrolling: Int = 0
    var fihsingRodDurability = 100
    var flag: Bool = false
    
    var viewModel: ViewModel
    
    init(viewModel: ViewModel){
        
        self.viewModel = viewModel
    }
    
    func simulaForzaPesce (pesce: Pesce) {
        
        timerEsterno = Timer.scheduledTimer(withTimeInterval: Double(pesce.movementSpeed + 1), repeats: true){ timerEsterno in
            
            self.timerInterno?.invalidate()
            self.observerTimer?.invalidate()
            
            previousScroll = 0
            scroll = 0
            
            let strenght = Int.random(in: pesce.minStrenght...pesce.maxStrenght)
            strenghtGlobal = strenght
            
            switch strenght {
                
            case 0:
                self.tempoIinterno = 1.0
                self.getRope(caso: 0, pesce: pesce)
                break
                
            case 1:
                self.tempoIinterno = 0.8
                self.getRope(caso: 1, pesce: pesce)
                break
                
            case 2:
                self.tempoIinterno = 0.6
                self.getRope(caso: 2, pesce: pesce)
                break
                
            case 3:
                self.tempoIinterno = 0.4
                self.getRope(caso: 3, pesce: pesce)
                break
                
            case 4:
                self.tempoIinterno = 0.2
                self.getRope(caso: 4, pesce: pesce)
                break
                
            case 5:
                self.tempoIinterno = 0.1
                self.getRope(caso: 5, pesce: pesce)
                break
                
                
                
            default: print("Errore nella generazione della forza")
                
                
            }
        }
    }
    
    private func getRope(caso: Int, pesce: Pesce){
        
        self.timerInterno = Timer.scheduledTimer(withTimeInterval: self.tempoIinterno, repeats: true){ timerInterno in
            self.hapticFeedback.makeVibration(chooseVibration: 3)
            if caso == 4 { self.vittoria += pesce.decreaseRopeLight }
            if caso == 5 { self.vittoria += pesce.decreaseRopeHeavy }
            
        }
        
        self.observerTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true){ observerTimer in
            
            self.manageCases(caso: caso, pesce: pesce)
            
        }
    }
    
    //Funzione che gestisce i casi di scroll
    private func manageCases(caso: Int, pesce: Pesce){
        
        //Se sto lasciando la lenza gestiscodi conseguenza
        if previousScroll < scroll {
            // print("Stai lanciando la lenza")
            
            // In base al caso andiamo ad allontanare la vittoria
            switch caso {
            case 0, 1 :
                print("Caso 0 1 aumento di \(pesce.takeRopeLight): \(vittoria)")
                self.vittoria += pesce.takeRopeLight
                break
                
            case 2, 3 :
                print("Caso 2 3 aumento di \(pesce.takeRopeLight): \(vittoria)")
                self.vittoria += pesce.takeRopeMedium
                break
                
            case 4, 5 :
                print("Caso 4 5 aumento di \(pesce.takeRopeLight): \(vittoria)")
                self.vittoria += pesce.takeRopeHeavy
                break
                
            default:
                print("Default case")
                break
                
            }
            
        //Caso in cui tiriamo la lenza verso di noi
        } else if previousScroll > scroll {
            // print("Stai tirando la lenza")
            
            // In base al caso gestiamo l'avicinamento al punto di vittoria
            switch caso {
            case 0, 1 :
                print("Caso 0 1 diminuisco di \(pesce.loseRopeHigh): \(vittoria)")
                self.vittoria -= pesce.loseRopeHigh
                break
                
            case 2, 3 :
                print("Caso 2 3 siminuisco di \(pesce.loseRopeHigh): \(vittoria)")
                self.vittoria -= pesce.loseRopeMedium
                break
                
            case 4, 5 :
                print("Caso 4 5 siminuisco di \(pesce.loseRopeHigh): \(vittoria)")
                self.vittoria -= pesce.loseRopeLight
                self.changeFRDurability(caso: caso, pesce: pesce)
                break
                
            default:
                print("Default case")
                break
                
            }
        }
        
        // Si invia l'attuale valore della vittoria per far aggiornare la barra nella scena spritekit
        viewModel.sendMessage(key: "Vittoria", value: self.vittoria)
        
        previousScroll = scroll
        
        self.checkVittoria()
        
    }
    
    func invalidateTimers(){
        self.timerEsterno?.invalidate()
        self.timerInterno?.invalidate()
        self.observerTimer?.invalidate()
        self.fihsingRodDurability = 100
        self.vittoria = 400
        viewModel.sendMessage(key: "frDurability", value: 100)
    }
    
    
    private func checkVittoria(){
        //Caso in cui vinciamo
        if self.vittoria <= 0 {
            condizioneVittoria = 0
            print("Hai vinto!")
            //Si resetta la variabile globale per permettere il lancio
            self.endSimulation()
            self.hapticFeedback.makeVibration(chooseVibration: 6)
        //Caso in cui perdiamo
        } else if self.vittoria > 600 {
            condizioneVittoria = 1
            print("Hai perso!")
            //Si resetta la variabile globale per permettere il lancio
            self.endSimulation()
            self.hapticFeedback.makeVibration(chooseVibration: 2)
        }
        
    }
    
    private func changeFRDurability(caso: Int, pesce: Pesce){
        
        // Viene diminuita di uno la rottura lenza dle pesce se non sta tirando al massimo
        var amount = 0
        if caso == 4 {
            amount = pesce.fishingRodBreakingSpeed - 1
        }
        
        print("Diminuisco la durab. della lenza di \(pesce.fishingRodBreakingSpeed): \(self.fihsingRodDurability)")
        self.fihsingRodDurability -= amount
        
        if self.fihsingRodDurability <= 0 {
            condizioneVittoria = 2
            print("Hai Rotto la lenza, esco dalla simulazione")
            //Si resetta la variabile globale per permettere il lancio
            self.endSimulation()
            self.hapticFeedback.makeVibration(chooseVibration: 2)
        }
        
        // Viene inviata la attuale durabilità
        viewModel.sendMessage(key: "frDurability", value: self.fihsingRodDurability)
    }
    
    private func endSimulation(){
        self.invalidateTimers()
    }
}



