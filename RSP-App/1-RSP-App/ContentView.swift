//
//  ContentView.swift
//  1-RSP-App
//
//  Created by Cruz Torres on 07/06/21.
//  Copyright © 2021 Cruz Torres. All rights reserved.
//

import SwiftUI

// Model
struct RSPGame {
    enum Move: String, CaseIterable {
        case rock = "✊🏼",
        scissors = "✌🏼",
        papers = "👋🏼"
        
        static var winningMoves: [Move : Move] {
            [
                .rock : .scissors,
                .papers : .rock,
                .scissors : .papers
            ]
        }
    }
    
    enum Player {
        case one, two
    }
    enum Result {
        case win, draw, loss
    }
    let allMoves = Move.allCases
    
    var activePlayer = Player.one
    
    var moves: (first: Move?, second: Move?) = (nil, nil){
        didSet {
            activePlayer = (moves.first != nil && activePlayer == .one) ? .two : .one
        }
    }
    var isGameOver: Bool {
        moves.first != nil && moves.second != nil
    }
    
    var winner: Player? = nil
    
    func evaluateResult() -> RSPGame.Result? {
        guard let firstMove = moves.first,
              let secondMove = moves.second else {
              return nil
        }
        
        // Draw Case
        if firstMove == secondMove {
            return.draw
        }
        if let neededMoveToWin = Move.winningMoves[firstMove],
            secondMove == neededMoveToWin {
            return .win
        }
        return .loss
    }
}

// ViewModel

final class RSPGameViewModel: ObservableObject {
    @Published private var model = RSPGame()
    
    func getAllowedMoves(forPlayer player: RSPGame.Player) -> [RSPGame.Move]{
        if model.activePlayer == player && !model.isGameOver {
            return model.allMoves
        }
        return []
    }
    
    func getStatusText(forPlayer player: RSPGame.Player) -> String {
        if !model.isGameOver{
            return model.activePlayer == player ? "" : "..."
        }
        if let result = model.evaluateResult() {
            switch result {
            case .win:
                return player == .one ? "You Won!" : "You Lost!"
            case .loss:
                return player == .one ? "You Lost!" : "You Won!"
            case .draw:
                return "DRAW!"
            }
        }
        return "Undefined state"
    }
    
    func getfinalMove(forPlayer player: RSPGame.Player) -> String {
        if model.isGameOver {
            switch player {
            case .one:
                return model.moves.first?.rawValue ?? ""
            case .two:
                return model.moves.second?.rawValue ?? ""
            }
        }
        return ""
    }
    
    func isGameOver() -> Bool {
        model.isGameOver
    }
    
    func choose(_ move: RSPGame.Move, forPlayer player: RSPGame.Player) {
        print("Player \(player) chose \(move.rawValue)")
        if player == .one {
            model.moves.first = move
        } else {
            model.moves.second = move
        }
    }
    func resetGame() {
        model.activePlayer = .one
        model.moves = (nil, nil)
        model.winner = nil
    }

}


// View
struct ContentView: View {
    
    @ObservedObject var viewModel = RSPGameViewModel()
    
    var body: some View {
        VStack{
            ZStack{
                Color(.purple)
                VStack{
                    Text("Player 2")
                    Spacer()
                    Text(viewModel.getfinalMove(forPlayer: .two))
                    Spacer()
                    Text(viewModel.getStatusText(forPlayer: .two))
                    HStack{
                        ForEach(viewModel.getAllowedMoves(forPlayer: .two), id: \.self) {
                            move in Button(action: {
                                self.viewModel
                                    .choose(move, forPlayer: .two)
                            }) {
                                Spacer()
                                Text(move.rawValue)
                                Spacer()
                            }
                        }
                    }
                }
                .padding(.bottom, 40)
            }
            .rotationEffect(.init(degrees: 180))
            
            // Todo: Retry Button
            if viewModel.isGameOver(){
                Button(action: {
                    self.viewModel.resetGame()
                    }) {
                    Text("Retry 🔄")
                        .foregroundColor(.blue)
                        .font(.custom("AvenirNext-UltraLight", size: 30))
                }
            }
            
            ZStack{
                Color(.blue)
                VStack{
                    Text("Player 1")
                    Spacer()
                    Text(viewModel.getfinalMove(forPlayer: .one))
                    Spacer()
                    Text(viewModel.getStatusText(forPlayer: .one))
                    HStack{
                        ForEach(viewModel.getAllowedMoves(forPlayer: .one), id: \.self) {
                            move in Button(action: {
                                self.viewModel
                                    .choose(move, forPlayer: .one)
                            }) {
                                Spacer()
                                Text(move.rawValue)
                                Spacer()
                            }
                        }
                    }
                }
                .padding(.bottom, 40)
            }
        }
        .font(.custom("AvenirNext-UltraLight", size: 80))
        .foregroundColor(.white)
        .edgesIgnoringSafeArea([.top, .bottom])
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
