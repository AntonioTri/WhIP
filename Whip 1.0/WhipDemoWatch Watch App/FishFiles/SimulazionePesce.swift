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
        
        let pesce = FishTemplate(type: viewModel.typeSpawned, rarity: viewModel.choosedRarity)
        print("Type: \(viewModel.typeSpawned).\nRarity: \(viewModel.choosedRarity).\n")
        // Pesce.getForza() Pesce.GetTempoDiAttesa()
        
        self.initialTimer = Timer.scheduledTimer(withTimeInterval: Double.random(in: 7...14), repeats: false){ initialTimer in
            self.startSimulation(pesce: pesce)
            self.initialTimer.invalidate()
        }
    }
    
    private func startSimulation(pesce: FishTemplate){
        
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
    
    private func tryToFish(pesce: FishTemplate){
        
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

