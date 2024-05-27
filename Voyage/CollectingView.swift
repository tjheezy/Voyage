//
//  CollectingView.swift
//  Voyage
//
//  Created by Graciella Adriani Seciawanto on 27/05/24.
//

import SwiftUI

struct CollectingView: View {
    @StateObject private var coordinator: BridgingCoordinator
    @State private var predictionResult: [Prediction] = [.none]
    @State private var isTapped: Bool = false
    
    init(){
        let coordinator = BridgingCoordinator()
        self._coordinator = StateObject(wrappedValue: coordinator)
    }
    
    var body: some View {
        ZStack {
            CameraView(bridgingCoordinator: coordinator) { image in
                
                if let img = image {
                    do {
                        try ImagePredictor().makePredictions(for: img) { predictions in
                            
                            if let firstPrediction = predictions?.first {
                                print("Prediction \(firstPrediction.classification)")
                                
                                switch (firstPrediction.classification) {
                                case "Sunscreen":
                                    predictionResult.append(.sunscreen)
                                case "Glasses":
                                    predictionResult.append(.glasses)
                                case "Drug":
                                    predictionResult.append(.drug)
                                case "WaterBottle":
                                    predictionResult.append(.waterBottle)
                                default:
                                    break
                                }
                            }
                        }
                    } catch {
                        print("Error predicting image: \(error.localizedDescription)")
                    }
                }
            }.ignoresSafeArea(.all, edges: .all)
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                .rotationEffect(.degrees(270))
            
            
            ForEach(predictionResult, id: \.hashValue) { prediction in
                        switch (prediction) {
                        case .sunscreen:
                            Image("Sunscreen")
                                .resizable()
                                .scaledToFit()
                                .zIndex(3)
                        case .glasses:
                            Image("Glasses")
                                .resizable()
                                .scaledToFit()
                                .zIndex(3)
                        case .drug:
                            Image("Drug")
                                .resizable()
                                .scaledToFit()
                                .zIndex(3)
                        case .waterBottle:
                            Image("WaterBottle")
                                .resizable()
                                .scaledToFit()
                                .zIndex(3)
                        default:
                            Image("CollectingThings")
                                .resizable()
                                .scaledToFit()
                                .zIndex(2)
                        }
                    }
            
        }
    }
}

#Preview {
    CollectingView()
}

enum Prediction {
    case drug
    case glasses
    case none
    case sunscreen
    case waterBottle
}

