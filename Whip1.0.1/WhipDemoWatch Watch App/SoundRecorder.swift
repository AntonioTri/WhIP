//
//  SoundRecorder.swift
//  WhipDemoWatch Watch App
//
//  Created by Andrea Siniscalchi on 13/04/24.
//

import Foundation
import SwiftUI
import AVFoundation

class SoundRecorder: NSObject, AVAudioRecorderDelegate{
    
    private var audioRecorder: AVAudioRecorder!
    private var observerTimer = Timer()
    let audioSession = AVAudioSession.sharedInstance()
    private var timeAboveThreshold: TimeInterval = 0
    private let thresholdDuration: TimeInterval = 1.0 // Durata minima sopra la soglia per considerare il suono

    
    let settings = [
        AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
        AVSampleRateKey: 44100,
        AVNumberOfChannelsKey: 1,
        AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
    ]
    
    override init(){
        super.init()
        self.requestMicrophonePermission()
        self.declareRecorder()
        self.declarationListener()
    }
    
    
    func startListening(hapticFishing: HapticFishing){
        
        print("In ascolto del microfono...")
        self.audioRecorder.prepareToRecord()
        self.audioRecorder.record()
        self.listen(hapticFishing: hapticFishing)

    }
    
    func stopListening(){
        
        self.audioRecorder.stop()
        self.observerTimer.invalidate()
        
        do {
            let fileManager = FileManager.default
            let audioFilename = getDocumentsDirectory().appendingPathComponent("recording.m4a")
            try fileManager.removeItem(at: audioFilename)
            print("File eliminato con successo.")
            
        } catch {
            print("Errore durante l'eliminazione del file audio: \(error)")
        }
        
    }
    
    private func listen(hapticFishing: HapticFishing){
        
        self.observerTimer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { _ in
            
            self.audioRecorder.updateMeters()
            let peakPower = self.audioRecorder.peakPower(forChannel: 0)
            
            if peakPower > -1.75 { // Imposta la soglia di rumore da considerare come "forte"
                if hapticFishing.fihsingRodDurability < 80 {
                    hapticFishing.fihsingRodDurability += 7
                    print("Aumento la durabilità di 2: \(hapticFishing.fihsingRodDurability)")
                    hapticFishing.viewModel.sendMessage(key: "canSpawnPopup", value: 1)
                    hapticFishing.viewModel.sendMessage(key: "frDurability", value: hapticFishing.fihsingRodDurability)
                    hapticFishing.viewModel.frDurability = hapticFishing.fihsingRodDurability
                }
            }
        }
    }
    
    private func declareRecorder()
    {
        let audioFilename = getDocumentsDirectory().appendingPathComponent("recording.m4a")
        do {
            self.audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            self.audioRecorder.delegate = self
            self.audioRecorder.isMeteringEnabled = true
            
        } catch {
            print("Errore durante l'inizializzazione del registratore audio: \(error)")
        }

    }
    
    func requestMicrophonePermission() {
        AVAudioSession.sharedInstance().requestRecordPermission { granted in
            if granted {
                print("Permesso al microfono ceduto")
            } else {
                print("Permesso al microfono non dato")
            }
        }
    }

    
    private func declarationListener(){
        do {
            try self.audioSession.setCategory(.playAndRecord)
            try self.audioSession.setActive(true)
        } catch {
            print("Errore durante la configurazione della sessione audio: \(error)")
        }
    }
    
    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}

