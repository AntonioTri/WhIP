//
//  ContentView.swift
//  WhipDemo
//
//  Created by Antonio Tridente on 11/03/24.
//

import SwiftUI
import SpriteKit
import UserNotifications

struct ContentView: View {
    
    @ObservedObject private var viewModel: ViewModel = ViewModel()
    
//    let savingCenter = SavingsCenter()
//    @State var showText: Bool = false
    
    var body: some View {
        Sview(viewModel: viewModel)
            .edgesIgnoringSafeArea(.all)
        

    }
    
}

//struct ContentView: View {
//    
//    @StateObject var notificationCenter = NotificationCenter()
//    
//    
//    let savingCenter = SavingsCenter()
//    
//    
//    @State var showText = false
//  
//    var body: some View {
//        Button(action: {
//            notificationCenter.sendNotification(title: "Titolo della notifica", body: "Corpo della notifica")
//        }) {
//            Text("Invia notifica")
//        }
//        .padding()
//        
//        Button(action: {
//            savingCenter.saveString(dataToSave: "mission 13 vinta!!!!!", key: savingKeys.MISSION_13)
//            savingCenter.saveBool(dataToSave: true, key: savingKeys.BOOLEAN_TEST)
//            savingCenter.saveInteger(dataToSave: 43151, key: savingKeys.INTEGER_TEST)
//        }, label: {
//            Text("Salva diversi dati")
//        })
//        .padding()
//        
//        Button(action: {
//            self.showText = true
//        }, label: {
//            Text("Mostra i dati salvati")
//        })
//        .padding()
//        
//        if self.showText {
//            Text("Saved data:\n\(savingCenter.getSavedString(key: savingKeys.MISSION_13))\n\(savingCenter.getSavedInteger(key: savingKeys.INTEGER_TEST))")
//        }
//        
//        if savingCenter.getSavedBool(key: savingKeys.BOOLEAN_TEST) {
//            Text("Booleano settato a true")
//        }

//        Button(action: {
//            savingCenter.saveIntArray(dataToSave: [18, 4521, 42, 53], key: savingCenter.INT_ARRAY_TEST)
//            showText = true
//        }, label: {
//            Text("Salva e mostra dati")
//        })
//
//        if showText {
//            Text("Saved array: \(savingCenter.getSavedIntArray(key: savingCenter.INT_ARRAY_TEST)[0]), \(savingCenter.getSavedIntArray(key: savingCenter.INT_ARRAY_TEST)[1]) ,\(savingCenter.getSavedIntArray(key: savingCenter.INT_ARRAY_TEST)[2]), \(savingCenter.getSavedIntArray(key: savingCenter.INT_ARRAY_TEST)[3])")
//        }
//
//    }
//    
//}





struct Sview: View {
    
   var viewModel: ViewModel
    
    var scene: SKScene{
        let scene = SKScene (fileNamed: "GameSceneIphone") as! SKScriptIphone
        scene.size = CGSize(width: 1634, height: 750)
        scene.scaleMode = .aspectFill
        scene.setViewModel(viewModel: viewModel)
        return scene
    }
    
    var body: some View {
        
        ZStack{
            SpriteView(scene: scene)
            
        }
    }
}

#Preview {
    ContentView()
}
