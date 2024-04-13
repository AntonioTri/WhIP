//
//  HapticFishing.swift
//  WhipDemoWatch Watch App
//
//  Created by Antonio Tridente on 13/04/24.
//

import Foundation


//This last class represents the fish captured who's trying to get away. It's based on the creation of a random number
//Representing the fish strenght, the time between the vibrations is managed by a switch case "casing" on the strenght variable

var condizioneVittoria = -1

class HapticFishing {
    
    var timerInterno: Timer?
    var timerEsterno: Timer?
    var observerTimer: Timer?
    var tempoIinterno = 0.0
    let hapticFeedback: HapticFeedback = HapticFeedback()
    let soundRecorder: SoundRecorder = SoundRecorder()
    var vittoria = 400
    var scrolling: Int = 0
    var fihsingRodDurability = 100
    var flag: Bool = false
    
    var viewModel: ViewModel
    
    init(viewModel: ViewModel){
        self.viewModel = viewModel
    }
    
    func simulaForzaPesce (pesce: FishTemplate) {
        
        // AckNowledgement per controllare se il segnale di pesca sia arrivato
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true){ timer in
            
            if self.viewModel.pescaRecieved == 1 {
                print("Pesca arrivato!\nProcedo con la simulazione")
                // Si accede al microfono
                self.soundRecorder.startListening(hapticFishing: self)
                // Si gestisce l'acknowledgement
                self.viewModel.pescaRecieved = 0
                // Si simula il pesce
                self.simulateStrenght(pesce: pesce)
                timer.invalidate()
            }
        }
    }
    
    private func simulateStrenght(pesce: FishTemplate){
        
        self.timerEsterno = Timer.scheduledTimer(withTimeInterval: Double(pesce.movementSpeed + 1), repeats: true){ timerEsterno in
            
            print("Simulo la forza")
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
    
    private func getRope(caso: Int, pesce: FishTemplate){
        
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
    private func manageCases(caso: Int, pesce: FishTemplate){
        
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
        } else if self.vittoria > 800 {
            condizioneVittoria = 1
            print("Hai perso!")
            //Si resetta la variabile globale per permettere il lancio
            self.endSimulation()
            self.hapticFeedback.makeVibration(chooseVibration: 2)
        }
        
    }
    
    private func changeFRDurability(caso: Int, pesce: FishTemplate){
        
        // Viene diminuita di uno la rottura lenza dle pesce se non sta tirando al massimo
        print("Diminuisco la durab. della lenza di \(pesce.fishingRodBreakingSpeed): \(self.fihsingRodDurability)")
        self.fihsingRodDurability -= pesce.fishingRodBreakingSpeed
        
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
        self.soundRecorder.stopListening()
    }
}



