//
//  ContentView.swift
//  Vibrations Watch App
//
//  Created by Antonio Tridente on 27/02/24.
//

import Foundation
import SwiftUI
import WatchKit
import SpriteKit
import CoreMotion
import AVFoundation


var scroll = 0.0
var previousScroll = 0.0

struct Sview: View {
    
    var viewModel: ViewModel
    
    var scene: SKScene{
        let scene = SKScene (fileNamed: "GameScene") as! GameSceneScript
        scene.size = CGSize(width: 140, height: 170)
        scene.scaleMode = .aspectFill
        scene.setViewModel(viewModel: viewModel)
        return scene
    }

    var body: some View {
        SpriteView(scene: scene)
    }
}

struct ContentView: View {
    
    @State private var isVibrating = false
    @State var scrollAmount = 50000.0
    @State var previousScrollAmount = 0.0
    @State var startTime: Date = Date()
    @State var speed: Double = 0.0
    @State private var valore = 1
    @State private var contatore = 1
    
    @State private var levelAngle: Double = 0.0
    @State private var force: Double?
    
    let minAngle: Double = 0.0
    let maxAngle: Double = 100000
    let maxRotationSpeed: Double = 20.0
    
    @State var deltaZ: Double = 0.0
    @State var deltaX: Double = 0.0
    @State private var isThrowing = false
    @State private var currentValue: Double = 0
    @State private var previousAcceleration: CMAcceleration?
    @State private var maxAcceleration: Double = 0.0
    @State private var gyroData: CMGyroData?
    let motionManager = CMMotionManager()
        
    @StateObject private var viewModel: ViewModel = ViewModel()

    var body: some View {
        
        let tempScrollAmount = scrollAmount
        
        
        ZStack {
            
            Text("")
                .focusable(true)
                .digitalCrownRotation($scrollAmount, from: minAngle, through: maxAngle, by:rotationSpeed())
                .onChange(of: scrollAmount) { newValue in
                    
                    scrollAmount = newValue
                    scroll = newValue
                    
                    previousScrollAmount = tempScrollAmount
                    previousScroll = tempScrollAmount
                    
                    let tempoTrascorso = Date().timeIntervalSince(startTime)
                    speed = abs(scrollAmount - previousScrollAmount) / tempoTrascorso
                    
                    startTime = Date()
                    
                    if force == nil {
                        force = calculateForce(leverAngle: newValue)
                    }
                    
                }
                
                .onAppear(perform:{
                    self.startGyroscopeUpdates()
                    self.startAccelerometerUpdates()
                    WKExtension.shared().isAutorotating = true
                    
                })
            
            //vista spritekit
            Sview(viewModel: viewModel)
                .edgesIgnoringSafeArea(.all)
            //Vista della leva
            LevaView(angle: $scrollAmount)
            
            
        }
        .padding()
        .onTapGesture {
            viewModel.sendMessage(key: "trowBait", value: 1)
        }
        
        
    }
    
    private func startAccelerometerUpdates() {
        motionManager.accelerometerUpdateInterval = 0.1
        if motionManager.isAccelerometerAvailable {
            motionManager.startAccelerometerUpdates(to: .main) { (data, error) in
                guard let acceleration = data?.acceleration else { return }
                
                self.handleAcceleration(acceleration)

            }
        }
    }
    
    
    private func startGyroscopeUpdates() {
        motionManager.gyroUpdateInterval = 0.1
        if motionManager.isGyroAvailable {
            motionManager.startGyroUpdates(to: .main) { (data, error) in
                guard let gyroData = data else { return }
                self.gyroData = gyroData
                
            }
        }
    }
    
    // Aggiorna il metodo handleAcceleration(_:) nel ContentView
    private func handleAcceleration(_ acceleration: CMAcceleration) {
        
        if viewModel.canTrow == 1 {
            
            currentValue = 0
            
            if let previousAcceleration = self.previousAcceleration {
                let deltaX = acceleration.x - previousAcceleration.x
                let deltaY = acceleration.y - previousAcceleration.y
                let deltaZ = acceleration.z - previousAcceleration.z
                let magnitude = sqrt(deltaX * deltaX + deltaY * deltaY + deltaZ * deltaZ)
                
                let maxAcceleration: Double = 2.0
                let speed = min(magnitude / maxAcceleration * 1000, 2000)
            
                currentValue = speed

                // Se il lancio è permesso e la forza è abbastanza elevata, viene segnalato
                // che il lancio è estato eseguito, andando a disattivare il lock a questo blocco
                // di codice per impedirne le future esecuzioni fin quando la flag non viene
                // resettata durante la fine della simulazione
                if viewModel.canTrow == 1 && currentValue > 1300 && deltaY > -0.50{
                    
                    // La funzione che gestisce la logica di lancio
                    self.handleTrow()
                    
                }
            }

            self.previousAcceleration = acceleration
            
        }

    }
    
    // La funzione che gestisce il segnale di lancio della canna
    private func handleTrow(){
        
        // print("Hai eseguito un lancio")
        
        currentValue = 0
        viewModel.maxAcceleration = 0
        print("Prima del secondo segnale")
        
        // Vengono gestiti gli ack
        if viewModel.canTrowSecondSignal == 1 {
            print("Dentro il secondo segnale, invio sengnale di lancio")
            viewModel.canTrow = 0
            viewModel.canTrowSecondSignal = 0
            setSemaferoRed = true
            viewModel.sendMessage(key: "trow", value: 1)
            self.handleHacknowledgement()
        }
        
    }
    
    // Gestione dell'ack per il lancio
    private func handleHacknowledgement(){
        // Si prelaziona un tempo alla fine del quale se il segnale non è stato ricevuto
        // Viene reimpostata la possibilità di lanciare
        Timer.scheduledTimer(withTimeInterval: 5, repeats: false){ _ in
            // Controllo per osservare se l'iphone ha ricevuto il segnale
            if viewModel.trowSignalRecieved == 0 {
                // Se il segnale non è arrivato, viene reimpostata la possibilitò di pescare
                viewModel.canTrow = 1
                viewModel.canTrowSecondSignal = 1
                setSemaferoGreen = true
                
            // Altrimenti il segnale è arrivato correttamente e viene resettato localmente
            } else {
                viewModel.canTrow = 0
                viewModel.trowSignalRecieved = 0
                viewModel.sendMessage(key: "trow", value: 0)
            }
        }
    }
    
    private func calculateForce(leverAngle: Double) -> Double {
        let maxForce: Double = 100.0
        let force = maxForce * (leverAngle / maxAngle)
        return force
    }
    
    private func rotationSpeed() -> Double {
        if let force = force {
            return maxRotationSpeed * (1 - force)
        } else {
            return maxRotationSpeed
        }
    }
}


struct LevaView: View {
    
    @Binding var angle: Double
    @State private var difference = 0.0
    @State private var canPlaysound: Bool = false
    @State private var previousAngle: Double = 0.0
    let pivotPoint = CGPoint(x: 0.30, y: 3)
    
    // Dichiarazione dell'istanza AVAudioPlayer
    let audioPlayer: AVAudioPlayer? = {
        guard let url = Bundle.main.url(forResource: "Lenza_lenta", withExtension: "mp3") else { return nil }
        let player = try? AVAudioPlayer(contentsOf: url)
        player?.enableRate = true
        player?.volume = 10
        player?.numberOfLoops = 0
        return player
    }()
    
    var body: some View {
       
        
        Image("leva")
            .resizable()
            .scaledToFit()
            .offset(x: -pivotPoint.x, y: -pivotPoint.y)
            .rotationEffect(.degrees(angle), anchor: .center)
            .offset(x: pivotPoint.x, y: pivotPoint.y)
            .scaleEffect(1.2)
            
        
    }
    

            
}

#Preview {
    ContentView()
}

