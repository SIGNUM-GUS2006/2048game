//
//  ContentView.swift
//  game2048
//
//  Created by Диана on 12.01.2025.
//

import SwiftUI
import SwiftData

@Model
class Record { // база данных
    @Attribute(.unique) var id: UUID
    var score : Int
    var date : Date
    
    init (score: Int, date: Date = Date.now)
    {
        self.id = UUID()
        self.score = score
        self.date = date
    }
}

var Board = GameBoard()
var score: Int = 0

class GameBoard: ObservableObject {
    @Published var board: [[Int?]] = [
        [nil, nil, nil, nil],
        [nil, nil, nil, nil],
        [nil, nil, nil, nil],
        [nil, nil, nil, nil]
    ]
    var newX = 0
    var newY = 0
    static let ColorMap =  [
        0:Color(#colorLiteral(red: 0.8036968112, green: 0.7560353875, blue: 0.7039339542, alpha: 1)),
        2: Color(#colorLiteral(red: 0.9316522479, green: 0.8934505582, blue: 0.8544340134, alpha: 1)),
        4: Color(#colorLiteral(red: 0.9296537042, green: 0.8780228496, blue: 0.7861451507, alpha: 1)),
        8: Color(#colorLiteral(red: 0.9504186511, green: 0.6943461895, blue: 0.4723204374, alpha: 1)),
        16: Color(#colorLiteral(red: 0.9621869922, green: 0.6018956304, blue: 0.3936881721, alpha: 1)),
        32:Color(#colorLiteral(red: 0.9640850425, green: 0.49890697, blue: 0.3777080476, alpha: 1)),
        64: Color(#colorLiteral(red: 0.9669782519, green: 0.406899184, blue: 0.2450104952, alpha: 1)),
        128: Color(#colorLiteral(red: 0.9315031767, green: 0.8115276694, blue: 0.4460085034, alpha: 1)),
        256: Color(#colorLiteral(red: 0.9288312197, green: 0.7997121811, blue: 0.3823960423, alpha: 1)),
        512: Color(#colorLiteral(red: 0.9315162301, green: 0.783490479, blue: 0.3152971864, alpha: 1)),
        1024: Color(#colorLiteral(red: 0.9308142066, green: 0.7592952847, blue: 0.179728806, alpha: 1)),
        2048: Color(#colorLiteral(red: 0.9308142066, green: 0.7592952847, blue: 0.179728806, alpha: 1)),
    ]
    
    func reset() { // сброс игрового поля
            board = [
                [nil, nil, nil, nil],
                [nil, nil, nil, nil],
                [nil, nil, nil, nil],
                [nil, nil, nil, nil]
            ]
            newTile()
            newTile()
        }
    
    func newTile() { // помещение 2-ки или 4-ки на рандомное место на поле
        newX = Int.random(in: 0..<4)
        newY = Int.random(in: 0..<4)
        let hasNil = board.contains { row in
            row.contains { $0 == nil }
        }
        if hasNil{
            while board[newX][newY] != nil {
                newX = Int.random(in: 0..<4)
                newY = Int.random(in: 0..<4)
            }
            board[newX][newY] = [2, 2, 2, 2, 2, 2, 2, 2, 2, 4].randomElement()
        }
    }
    
    func removeNils(){ // удаляет все нилы из строки для удобства сложения одиноковых плиток
        var boardCopy = Board.board.map( { $0 } );
        for i in 0..<4{
            var okFlag = true;
            while okFlag{
                okFlag = false;
                for j in 0..<boardCopy[i].count{
                    if boardCopy[i][j] == nil {
                        Board.board[i].remove(at: j)
                        boardCopy = Board.board.map( { $0 } );
                        okFlag = true;
                        break
                    }
                }
            }
        }
    }
    
    func swipeRight(){
        removeNils()
        let boardCopy = Board.board.map( { $0 } );
        for i in 0..<4
        {
            for j in stride(from: boardCopy[i].count - 1, through: -1, by: -1){
                if j - 1 > -1{
                    if boardCopy[i][j] == boardCopy[i][j - 1]{ // если соседние плитки совпадают, то складываем их и в начало строки приписываем нил
                        if Board.board[i][j] != nil{
                            Board.board[i][j] = (Board.board[i][j]!) * 2;
                            score += Board.board[i][j]!
                            Board.board[i].remove(at: j - 1)
                            Board.board[i] = [nil] + Board.board[i]}
                    }
                }
            }
        }
        for i in 0..<4{ // восстанавливаем удаленные ранее нилы
            while Board.board[i].count < 4{
                Board.board[i] = [nil] + Board.board[i]
            }
        }
    }
    
    func swipeLeft(){
        removeNils()
        let boardCopy = Board.board.map( { $0 } );
        for i in 0..<4
        {
            if boardCopy[i].count > 0 { // соседние плитки складываем в конец добавляем нил
                for j in stride(from: 0, to: boardCopy[i].count, by: 1){
                    if j + 1 < boardCopy[i].count && Board.board[i][j] != nil{
                        if boardCopy[i][j] == boardCopy[i][j + 1]{
                            Board.board[i][j]! = (Board.board[i][j]!) * 2;
                            score += Board.board[i][j]!
                            Board.board[i].remove(at: j + 1)
                            Board.board[i] = Board.board[i] + [nil]
                        }
                    }
                }
            }
        }
        for i in 0..<4{ // восстанавливаем удаленные ранее нилы
            while Board.board[i].count < 4{
                Board.board[i] = Board.board[i] + [nil]          }
        }
    }
    
    func swipeUp(){
        var Tboard: [[Int?]] = [[nil, nil, nil, nil], [nil, nil, nil, nil], [nil, nil, nil, nil], [nil, nil, nil, nil]]; // транспонируем поле
        for i in 0..<4{
            for j in 0..<4{
                Tboard[j][i] = Board.board[i][j];
            }
        }
        Board.board = Tboard.map( { $0 } );
        swipeLeft() // делаем свайп влево
        for i in 0..<4{ // обратно транспонируем
            for j in 0..<4{
                Tboard[i][j] = Board.board[j][i];
            }
        }
        Board.board = Tboard.map( { $0 } );
    }
    
    func swipeDown(){
        var Tboard: [[Int?]] = [[nil, nil, nil, nil], [nil, nil, nil, nil], [nil, nil, nil, nil], [nil, nil, nil, nil]]; // транспонируем поле
        for i in 0..<4{
            for j in 0..<4{
                Tboard[j][i] = Board.board[i][j];
            }
        }
        Board.board = Tboard.map( { $0 } );
        swipeRight() // свайп вправо
        for i in 0..<4{ // обратно транспонируем
            for j in 0..<4{
                Tboard[i][j] = Board.board[j][i];
            }
        }
        Board.board = Tboard.map( { $0 } );
    }
    
    func IsEqualTiles() -> Bool { // функция которая проверяет есть ли на поле еще 2 соседних одинаковых плитки, rоторые можно сложить
        var equalFlag = false;
        for i in 0..<4{
            for j in 0..<3{
                if board[i][j] == board[i][j + 1]{
                    equalFlag = true;
                }
                else if board[j][i] == board[j + 1][i]{
                    equalFlag = true;
                }
            }
        }
        return equalFlag;
    }
    
    func GameOverCheck() -> Bool{ // проверка на то закончена ли игра
        let hasEmptyTile = board.contains { row in
                    row.contains { $0 == nil }
                }
        if !hasEmptyTile && !IsEqualTiles(){ // закончена если нет нилов на поле и нет соседних одинаковых плитки
            return true;
        }
        return false;
    }
}


struct LeaderboardView: View { // отображение таблицы рекордов 
    @Query(sort: \Record.score, order: .reverse) private var records: [Record]
    
    var body: some View {
        NavigationView {
            List(records) { record in
                HStack {
                    VStack(alignment: .leading) {
                        Text("Score: \(record.score)")
                            .font(.headline)
                        Text(record.date, style: .date)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                }
            }
            .navigationTitle("Leaderboard")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                            windowScene.windows.first?.rootViewController?.dismiss(animated: true)
                        }
                    }
                }
            }
        }
    }
}

struct ContentView: View {
    
    @StateObject var gameBoard = Board
    @Environment(\.modelContext) private var modelContext
    @State private var isLeaderboardVisible = false
    
    func restart() { // сброс игры
        saveScore()
            gameBoard.reset()
            score = 0
        }
    
    func saveScore() { // сохраняем очки в базу данных
            let newRecord = Record(score: score)
            modelContext.insert(newRecord)
        }
    
    var body: some View {
        VStack {
                Text("Score: \(score)")
                    .font(.largeTitle)
                    .bold()
                    .padding()
                    
            // Отображение игрового поля
            VStack(spacing: 8) { // Используем VStack для строк
                ForEach(0..<4, id: \.self) { row in
                    HStack(spacing: 8) { // Используем HStack для столбцов
                        ForEach(0..<4, id: \.self) { column in
                            ZStack {
                                Rectangle()
                                    .fill(GameBoard.ColorMap[gameBoard.board[row][column] ?? 0] ?? Color.gray.opacity(0.2))
                                    .frame(width: 80, height: 80)
                                    .cornerRadius(8)
                                
                                if let value = gameBoard.board[row][column] {
                                    Text("\(value)")
                                        .font(.title)
                                        .foregroundColor(.black)
                                } else {
                                    Text("")
                                        .font(.title)
                                }
                            }
                        }
                    }
                }
            }
            .padding()
            
            
            
            Button("Restart") {
                restart()
                                }
                                .padding()
                                .background(Color.red)
                                .foregroundColor(.white)
                                .cornerRadius(8)
            Button("Records") {
                                isLeaderboardVisible = true
                            }
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
        }
        .gesture(
            DragGesture()
                .onEnded { gesture in
                    if gesture.translation.width > 50 && abs(gesture.translation.height) < 30 {
                        // Свайп вправо
                        gameBoard.swipeRight()
                        gameBoard.newTile()
                    } else if gesture.translation.width < -50 && abs(gesture.translation.height) < 30 {
                        // Свайп влево
                        gameBoard.swipeLeft()
                        gameBoard.newTile()
                        
                    } else if gesture.translation.height < -50 && abs(gesture.translation.width) < 30 {
                        gameBoard.swipeUp() // вверх
                        gameBoard.newTile()
                    } else if gesture.translation.height > 50 && abs(gesture.translation.width) < 30{
                        gameBoard.swipeDown() // вниз
                        gameBoard.newTile()
                    }
                    
                }).sheet(isPresented: $isLeaderboardVisible) {
                    LeaderboardView()
                }
                    if gameBoard.GameOverCheck() {
                        Color.black.opacity(0.5) // Полупрозрачный фон
                            .edgesIgnoringSafeArea(.all)
                        
                        VStack {
                            Text("Game Over!")
                                .font(.largeTitle)
                                .bold()
                                .foregroundColor(.blue)
                                .padding()
                            Button("Restart") {
                                restart()
                            }
                            .padding()
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                            
                        }
                    }
    }
}
#Preview {
    ContentView()
}
