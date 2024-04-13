//
//  ContentView.swift
//  WhipDemo
//
//  Created by Antonio Tridente on 11/03/24.
//

import SwiftUI
import SpriteKit

struct ContentView: View {
    
    @ObservedObject private var viewModel: ViewModel = ViewModel()
    var body: some View {
        Sview(viewModel: viewModel)
            .edgesIgnoringSafeArea(.all)
        
    }
    
}


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
        
        SpriteView(scene: scene)
            
    }
}

#Preview {
    ContentView()
}
