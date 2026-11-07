//
//  ContentView.swift
//  Empire Tycoon
//
//  A complete Monopoly style board game for iPhone (SwiftUI, iOS 17 or newer).
//  Replace the entire content of your ContentView.swift with this file.
//

import SwiftUI
import Combine
import UIKit

// MARK: - Theme

enum Theme {
    static let background = LinearGradient(
        colors: [Color(red: 0.05, green: 0.09, blue: 0.20), Color(red: 0.02, green: 0.22, blue: 0.30)],
        startPoint: .top,
        endPoint: .bottom
    )
    static let gold = Color(red: 1.0, green: 0.82, blue: 0.30)
    static let card = Color.white.opacity(0.08)
}

// MARK: - Haptics

@MainActor
enum Haptics {
    static func tap() { UIImpactFeedbackGenerator(style: .light).impactOccurred() }
    static func heavy() { UIImpactFeedbackGenerator(style: .heavy).impactOccurred() }
    static func success() { UINotificationFeedbackGenerator().notificationOccurred(.success) }
    static func warning() { UINotificationFeedbackGenerator().notificationOccurred(.warning) }
}

// MARK: - Board Models

enum ColorGroup {
    case brown, lightBlue, pink, orange, red, yellow, green, darkBlue

    var color: Color {
        switch self {
        case .brown: return Color(red: 0.55, green: 0.33, blue: 0.20)
        case .lightBlue: return Color(red: 0.55, green: 0.80, blue: 0.95)
        case .pink: return Color(red: 0.90, green: 0.35, blue: 0.65)
        case .orange: return Color(red: 0.97, green: 0.60, blue: 0.15)
        case .red: return Color(red: 0.86, green: 0.15, blue: 0.18)
        case .yellow: return Color(red: 0.98, green: 0.85, blue: 0.20)
        case .green: return Color(red: 0.12, green: 0.62, blue: 0.35)
        case .darkBlue: return Color(red: 0.10, green: 0.27, blue: 0.70)
        }
    }

    var houseCost: Int {
        switch self {
        case .brown, .lightBlue: return 50
        case .pink, .orange: return 100
        case .red, .yellow: return 150
        case .green, .darkBlue: return 200
        }
    }
}

enum SquareKind: Equatable {
    case go
    case property(ColorGroup)
    case railroad
    case utility
    case surprise
    case treasure
    case tax(Int)
    case jail
    case restStop
    case goToJail
}

struct Square: Identifiable {
    let id: Int
    let name: String
    let kind: SquareKind
    var price: Int = 0
    var rents: [Int] = []

    var mortgageValue: Int { price / 2 }

    var isBuyable: Bool {
        switch kind {
        case .property, .railroad, .utility: return true
        default: return false
        }
    }

    var group: ColorGroup? {
        if case .property(let g) = kind { return g }
        return nil
    }
}

enum TileEdge {
    case bottom, left, top, right, corner
}

enum Board {
    static let squares: [Square] = [
        Square(id: 0, name: "GO", kind: .go),
        Square(id: 1, name: "Lisbon", kind: .property(.brown), price: 60, rents: [2, 10, 30, 90, 160, 250]),
        Square(id: 2, name: "Treasure", kind: .treasure),
        Square(id: 3, name: "Porto", kind: .property(.brown), price: 60, rents: [4, 20, 60, 180, 320, 450]),
        Square(id: 4, name: "Income Tax", kind: .tax(200)),
        Square(id: 5, name: "North Station", kind: .railroad, price: 200),
        Square(id: 6, name: "Athens", kind: .property(.lightBlue), price: 100, rents: [6, 30, 90, 270, 400, 550]),
        Square(id: 7, name: "Surprise", kind: .surprise),
        Square(id: 8, name: "Valencia", kind: .property(.lightBlue), price: 100, rents: [6, 30, 90, 270, 400, 550]),
        Square(id: 9, name: "Seville", kind: .property(.lightBlue), price: 120, rents: [8, 40, 100, 300, 450, 600]),
        Square(id: 10, name: "Jail", kind: .jail),
        Square(id: 11, name: "Naples", kind: .property(.pink), price: 140, rents: [10, 50, 150, 450, 625, 750]),
        Square(id: 12, name: "Power Co.", kind: .utility, price: 150),
        Square(id: 13, name: "Milan", kind: .property(.pink), price: 140, rents: [10, 50, 150, 450, 625, 750]),
        Square(id: 14, name: "Turin", kind: .property(.pink), price: 160, rents: [12, 60, 180, 500, 700, 900]),
        Square(id: 15, name: "East Station", kind: .railroad, price: 200),
        Square(id: 16, name: "Barcelona", kind: .property(.orange), price: 180, rents: [14, 70, 200, 550, 750, 950]),
        Square(id: 17, name: "Treasure", kind: .treasure),
        Square(id: 18, name: "Vienna", kind: .property(.orange), price: 180, rents: [14, 70, 200, 550, 750, 950]),
        Square(id: 19, name: "Prague", kind: .property(.orange), price: 200, rents: [16, 80, 220, 600, 800, 1000]),
        Square(id: 20, name: "Rest Stop", kind: .restStop),
        Square(id: 21, name: "Brussels", kind: .property(.red), price: 220, rents: [18, 90, 250, 700, 875, 1050]),
        Square(id: 22, name: "Surprise", kind: .surprise),
        Square(id: 23, name: "Amsterdam", kind: .property(.red), price: 220, rents: [18, 90, 250, 700, 875, 1050]),
        Square(id: 24, name: "Berlin", kind: .property(.red), price: 240, rents: [20, 100, 300, 750, 925, 1100]),
        Square(id: 25, name: "South Station", kind: .railroad, price: 200),
        Square(id: 26, name: "Munich", kind: .property(.yellow), price: 260, rents: [22, 110, 330, 800, 975, 1150]),
        Square(id: 27, name: "Madrid", kind: .property(.yellow), price: 260, rents: [22, 110, 330, 800, 975, 1150]),
        Square(id: 28, name: "Water Co.", kind: .utility, price: 150),
        Square(id: 29, name: "Rome", kind: .property(.yellow), price: 280, rents: [24, 120, 360, 850, 1025, 1200]),
        Square(id: 30, name: "Go To Jail", kind: .goToJail),
        Square(id: 31, name: "Dublin", kind: .property(.green), price: 300, rents: [26, 130, 390, 900, 1100, 1275]),
        Square(id: 32, name: "Zurich", kind: .property(.green), price: 300, rents: [26, 130, 390, 900, 1100, 1275]),
        Square(id: 33, name: "Treasure", kind: .treasure),
        Square(id: 34, name: "Paris", kind: .property(.green), price: 320, rents: [28, 150, 450, 1000, 1200, 1400]),
        Square(id: 35, name: "West Station", kind: .railroad, price: 200),
        Square(id: 36, name: "Surprise", kind: .surprise),
        Square(id: 37, name: "Monaco", kind: .property(.darkBlue), price: 350, rents: [35, 175, 500, 1100, 1300, 1500]),
        Square(id: 38, name: "Luxury Tax", kind: .tax(100)),
        Square(id: 39, name: "London", kind: .property(.darkBlue), price: 400, rents: [50, 200, 600, 1400, 1700, 2000])
    ]

    /// Column and row (0 to 10) of a square on the 11 by 11 grid. GO is bottom right.
    static func gridPosition(_ i: Int) -> (col: Int, row: Int) {
        switch i {
        case 0...10: return (10 - i, 10)
        case 11...19: return (0, 10 - (i - 10))
        case 20...30: return (i - 20, 0)
        default: return (10, i - 30)
        }
    }

    static func edge(of i: Int) -> TileEdge {
        switch i {
        case 1...9: return .bottom
        case 11...19: return .left
        case 21...29: return .top
        case 31...39: return .right
        default: return .corner
        }
    }
}

// MARK: - Cards

enum CardAction {
    case collect(Int)
    case pay(Int)
    case advanceTo(Int)
    case goToJail
    case getOutOfJail
    case moveBack(Int)
    case nearestRailroad
    case nearestUtility
    case payEachPlayer(Int)
    case collectFromEachPlayer(Int)
    case repairs(house: Int, hotel: Int)
}

struct Card {
    let text: String
    let action: CardAction
}

enum Cards {
    static let surprise: [Card] = [
        Card(text: "Advance to GO. Collect $200.", action: .advanceTo(0)),
        Card(text: "Take a trip to Rome. If you pass GO, collect $200.", action: .advanceTo(29)),
        Card(text: "Advance to Berlin. If you pass GO, collect $200.", action: .advanceTo(24)),
        Card(text: "Take a ride to West Station. If you pass GO, collect $200.", action: .advanceTo(35)),
        Card(text: "Advance to the nearest station. Pay the owner double rent.", action: .nearestRailroad),
        Card(text: "Advance to the nearest utility. Pay the owner 10 times the dice roll.", action: .nearestUtility),
        Card(text: "The bank pays you a dividend of $50.", action: .collect(50)),
        Card(text: "Get Out of Jail Free. Keep this card until you need it.", action: .getOutOfJail),
        Card(text: "Go back 3 spaces.", action: .moveBack(3)),
        Card(text: "Go directly to Jail. Do not pass GO.", action: .goToJail),
        Card(text: "Speeding fine. Pay $15.", action: .pay(15)),
        Card(text: "You are elected chairman. Pay each player $50.", action: .payEachPlayer(50)),
        Card(text: "Your building loan matures. Collect $150.", action: .collect(150)),
        Card(text: "General repairs: pay $25 per house and $100 per hotel.", action: .repairs(house: 25, hotel: 100))
    ]

    static let treasure: [Card] = [
        Card(text: "Bank error in your favor. Collect $200.", action: .collect(200)),
        Card(text: "Doctor's fee. Pay $50.", action: .pay(50)),
        Card(text: "You sold some stock. Collect $50.", action: .collect(50)),
        Card(text: "Get Out of Jail Free. Keep this card until you need it.", action: .getOutOfJail),
        Card(text: "Go directly to Jail. Do not pass GO.", action: .goToJail),
        Card(text: "Holiday fund matures. Collect $100.", action: .collect(100)),
        Card(text: "Income tax refund. Collect $20.", action: .collect(20)),
        Card(text: "It is your birthday. Collect $10 from every player.", action: .collectFromEachPlayer(10)),
        Card(text: "Hospital fees. Pay $100.", action: .pay(100)),
        Card(text: "School fees. Pay $50.", action: .pay(50)),
        Card(text: "Consultancy fee. Receive $25.", action: .collect(25)),
        Card(text: "Street repairs: pay $40 per house and $115 per hotel.", action: .repairs(house: 40, hotel: 115)),
        Card(text: "You won second prize in a talent show. Collect $10.", action: .collect(10)),
        Card(text: "You inherit $100.", action: .collect(100)),
        Card(text: "Advance to GO. Collect $200.", action: .advanceTo(0))
    ]
}

// MARK: - Game Models

struct Player: Identifiable {
    let id: Int
    var name: String
    var token: String
    var isAI: Bool
    var money = 1500
    var position = 0
    var inJail = false
    var jailTurns = 0
    var getOutCards = 0
    var bankrupt = false

    static let palette: [Color] = [.blue, .red, .green, .purple]
    var color: Color { Player.palette[id % 4] }
}

enum Phase: Equatable {
    case needsRoll, decideBuy, postMove, auction, gameOver
}

enum LandResult {
    case resolved, needsDecision
}

struct LogEntry: Identifiable {
    let id = UUID()
    let text: String
}

struct CardPopup: Identifiable {
    let id = UUID()
    let title: String
    let text: String
    let isSurprise: Bool
}

struct Auction {
    var index: Int
    var bid: Int = 0
    var highBidder: Int?
    var active: [Int]
    var turn: Int = 0
}

struct SquareSelection: Identifiable {
    let id: Int
}

// MARK: - Game Engine

@MainActor
final class GameEngine: ObservableObject {
    let board = Board.squares

    @Published var players: [Player]
    @Published var current = 0
    @Published var owner: [Int?] = Array(repeating: nil, count: 40)
    @Published var houses: [Int] = Array(repeating: 0, count: 40)
    @Published var mortgaged: [Bool] = Array(repeating: false, count: 40)
    @Published var die1 = 1
    @Published var die2 = 1
    @Published var isRolling = false
    @Published var phase: Phase = .needsRoll
    @Published var isBusy = false
    @Published var log: [LogEntry] = []
    @Published var cardPopup: CardPopup?
    @Published var auction: Auction?
    @Published var winner: Int?

    private var surpriseDeck: [Card] = []
    private var treasureDeck: [Card] = []
    private var doublesCount = 0
    private var rolledDouble = false
    private var aiToken = 0

    init(players: [Player]) {
        self.players = players
        surpriseDeck = Cards.surprise.shuffled()
        treasureDeck = Cards.treasure.shuffled()
        addLog("Game on! Everyone starts with $1500.")
        setPhase(.needsRoll)
    }

    // MARK: Queries

    func addLog(_ text: String) {
        log.insert(LogEntry(text: text), at: 0)
        if log.count > 80 { log.removeLast() }
    }

    func properties(of pi: Int) -> [Int] {
        var result: [Int] = []
        for i in 0..<40 where owner[i] == pi { result.append(i) }
        return result
    }

    func groupIndices(_ g: ColorGroup) -> [Int] {
        board.filter { $0.group == g }.map { $0.id }
    }

    func ownsFullGroup(_ pi: Int, _ g: ColorGroup) -> Bool {
        groupIndices(g).allSatisfy { owner[$0] == pi }
    }

    func netWorth(_ pi: Int) -> Int {
        var total = players[pi].money
        for i in properties(of: pi) {
            total += mortgaged[i] ? board[i].mortgageValue : board[i].price
            if let g = board[i].group { total += houses[i] * g.houseCost }
        }
        return total
    }

    func rent(at index: Int, utilityTenX: Bool = false) -> Int {
        guard let o = owner[index] else { return 0 }
        let sq = board[index]
        switch sq.kind {
        case .property(let g):
            let h = houses[index]
            if h > 0 { return sq.rents[h] }
            return ownsFullGroup(o, g) ? sq.rents[0] * 2 : sq.rents[0]
        case .railroad:
            var count = 0
            for i in [5, 15, 25, 35] where owner[i] == o { count += 1 }
            return 25 * (1 << max(count - 1, 0))
        case .utility:
            var count = 0
            for i in [12, 28] where owner[i] == o { count += 1 }
            let multiplier = (utilityTenX || count == 2) ? 10 : 4
            return multiplier * (die1 + die2)
        default:
            return 0
        }
    }

    // MARK: Turn flow

    func rollDice() {
        guard phase == .needsRoll, !isBusy, winner == nil else { return }
        isBusy = true
        Task { await performRoll() }
    }

    private func performRoll() async {
        isRolling = true
        for _ in 0..<9 {
            die1 = Int.random(in: 1...6)
            die2 = Int.random(in: 1...6)
            Haptics.tap()
            try? await Task.sleep(nanoseconds: 70_000_000)
        }
        isRolling = false

        let d1 = Int.random(in: 1...6)
        let d2 = Int.random(in: 1...6)
        die1 = d1
        die2 = d2
        let total = d1 + d2
        let isDouble = d1 == d2
        let name = players[current].name
        addLog("\(name) rolled \(d1) and \(d2)\(isDouble ? " (doubles)" : "").")

        if players[current].inJail {
            if isDouble {
                players[current].inJail = false
                players[current].jailTurns = 0
                rolledDouble = false
                addLog("Doubles! \(name) is free.")
                let result = await move(steps: total)
                finishMove(result)
            } else {
                players[current].jailTurns += 1
                rolledDouble = false
                if players[current].jailTurns >= 3 {
                    addLog("Third failed try. \(name) pays $50 and leaves jail.")
                    players[current].inJail = false
                    players[current].jailTurns = 0
                    if charge(current, 50, to: nil) {
                        let result = await move(steps: total)
                        finishMove(result)
                    } else {
                        settleTurn()
                    }
                } else {
                    addLog("No luck. \(name) stays in jail.")
                    settleTurn()
                }
            }
            return
        }

        if isDouble { doublesCount += 1 } else { doublesCount = 0 }
        if doublesCount >= 3 {
            addLog("Three doubles in a row! \(name) goes straight to jail.")
            sendToJail(current)
            rolledDouble = false
            settleTurn()
            return
        }
        rolledDouble = isDouble
        let result = await move(steps: total)
        finishMove(result)
    }

    private func move(steps: Int) async -> LandResult {
        for _ in 0..<steps {
            stepForward()
            try? await Task.sleep(nanoseconds: 150_000_000)
        }
        return await land()
    }

    private func stepForward() {
        let next = (players[current].position + 1) % 40
        players[current].position = next
        if next == 0 {
            players[current].money += 200
            addLog("\(players[current].name) collects $200 from GO.")
            Haptics.success()
        } else {
            Haptics.tap()
        }
    }

    private func advance(to target: Int) async {
        while players[current].position != target {
            stepForward()
            try? await Task.sleep(nanoseconds: 110_000_000)
        }
    }

    private func stepBack(_ n: Int) async {
        for _ in 0..<n {
            players[current].position = (players[current].position + 39) % 40
            Haptics.tap()
            try? await Task.sleep(nanoseconds: 150_000_000)
        }
    }

    private func sendToJail(_ pi: Int) {
        players[pi].position = 10
        players[pi].inJail = true
        players[pi].jailTurns = 0
        addLog("\(players[pi].name) goes to jail.")
        Haptics.warning()
    }

    private func land(railroadDouble: Bool = false, utilityTenX: Bool = false) async -> LandResult {
        let pos = players[current].position
        let sq = board[pos]
        let name = players[current].name
        switch sq.kind {
        case .go, .jail, .restStop:
            break
        case .goToJail:
            sendToJail(current)
        case .tax(let amount):
            addLog("\(name) pays $\(amount) in tax.")
            _ = charge(current, amount, to: nil)
        case .surprise:
            return await drawCard(surprise: true)
        case .treasure:
            return await drawCard(surprise: false)
        case .property, .railroad, .utility:
            if let o = owner[pos] {
                if o != current && !mortgaged[pos] {
                    var due = rent(at: pos, utilityTenX: utilityTenX)
                    if railroadDouble { due *= 2 }
                    addLog("\(name) pays $\(due) rent to \(players[o].name) for \(sq.name).")
                    _ = charge(current, due, to: o)
                }
            } else {
                addLog("\(name) landed on \(sq.name) for $\(sq.price).")
                return .needsDecision
            }
        }
        return .resolved
    }

    private func drawCard(surprise: Bool) async -> LandResult {
        let card: Card
        if surprise { card = surpriseDeck.removeFirst() } else { card = treasureDeck.removeFirst() }
        var keeper = false
        if case .getOutOfJail = card.action { keeper = true }
        if !keeper {
            if surprise { surpriseDeck.append(card) } else { treasureDeck.append(card) }
        }
        let title = surprise ? "Surprise" : "Treasure"
        cardPopup = CardPopup(title: title, text: card.text, isSurprise: surprise)
        addLog("\(title): \(card.text)")
        try? await Task.sleep(nanoseconds: 2_200_000_000)
        cardPopup = nil
        return await apply(card.action)
    }

    private func apply(_ action: CardAction) async -> LandResult {
        let name = players[current].name
        switch action {
        case .collect(let a):
            players[current].money += a
            return .resolved
        case .pay(let a):
            _ = charge(current, a, to: nil)
            return .resolved
        case .advanceTo(let t):
            await advance(to: t)
            return await land()
        case .goToJail:
            sendToJail(current)
            return .resolved
        case .getOutOfJail:
            players[current].getOutCards += 1
            addLog("\(name) keeps a Get Out of Jail Free card.")
            return .resolved
        case .moveBack(let n):
            await stepBack(n)
            return await land()
        case .nearestRailroad:
            await advance(to: nearest(of: [5, 15, 25, 35]))
            return await land(railroadDouble: true)
        case .nearestUtility:
            await advance(to: nearest(of: [12, 28]))
            return await land(utilityTenX: true)
        case .payEachPlayer(let a):
            for i in players.indices where i != current && !players[i].bankrupt {
                if !charge(current, a, to: i) { break }
            }
            return .resolved
        case .collectFromEachPlayer(let a):
            for i in players.indices where i != current && !players[i].bankrupt {
                _ = charge(i, a, to: current)
            }
            return .resolved
        case .repairs(let h, let hotel):
            var total = 0
            for i in properties(of: current) {
                total += (houses[i] == 5) ? hotel : houses[i] * h
            }
            if total > 0 {
                addLog("\(name) pays $\(total) for repairs.")
                _ = charge(current, total, to: nil)
            }
            return .resolved
        }
    }

    private func nearest(of spots: [Int]) -> Int {
        let pos = players[current].position
        return spots.first(where: { $0 > pos }) ?? spots[0]
    }

    private func finishMove(_ result: LandResult) {
        if winner != nil {
            isBusy = false
            return
        }
        if result == .needsDecision && !players[current].bankrupt {
            isBusy = false
            setPhase(.decideBuy)
        } else {
            settleTurn()
        }
    }

    private func settleTurn() {
        isBusy = false
        if winner != nil { return }
        if players[current].bankrupt {
            advanceTurn()
            return
        }
        if rolledDouble && !players[current].inJail {
            addLog("Doubles! \(players[current].name) rolls again.")
            setPhase(.needsRoll)
        } else {
            setPhase(.postMove)
        }
    }

    func endTurn() {
        guard phase == .postMove, !isBusy else { return }
        advanceTurn()
    }

    private func advanceTurn() {
        guard players.contains(where: { !$0.bankrupt }) else { return }
        doublesCount = 0
        rolledDouble = false
        var next = current
        repeat {
            next = (next + 1) % players.count
        } while players[next].bankrupt
        current = next
        setPhase(.needsRoll)
    }

    private func setPhase(_ newPhase: Phase) {
        phase = newPhase
        if newPhase == .gameOver { return }
        if newPhase == .auction {
            if let a = auction, !a.active.isEmpty, players[a.active[a.turn]].isAI {
                scheduleAI()
            }
        } else if players[current].isAI {
            scheduleAI(after: newPhase == .postMove ? 1.3 : 0.8)
        }
    }

    // MARK: Buying and jail

    func buyCurrent() {
        guard phase == .decideBuy, !isBusy else { return }
        let pos = players[current].position
        let price = board[pos].price
        guard players[current].money >= price else { return }
        players[current].money -= price
        owner[pos] = current
        addLog("\(players[current].name) bought \(board[pos].name) for $\(price).")
        Haptics.success()
        settleTurn()
    }

    func declineBuy() {
        guard phase == .decideBuy, !isBusy else { return }
        let pos = players[current].position
        addLog("\(players[current].name) passes on \(board[pos].name). Auction time!")
        startAuction(for: pos)
    }

    func payJailFine() {
        guard phase == .needsRoll, !isBusy, players[current].inJail, players[current].money >= 50 else { return }
        players[current].money -= 50
        players[current].inJail = false
        players[current].jailTurns = 0
        addLog("\(players[current].name) pays $50 and leaves jail.")
        Haptics.tap()
    }

    func useJailCard() {
        guard phase == .needsRoll, !isBusy, players[current].inJail, players[current].getOutCards > 0 else { return }
        players[current].getOutCards -= 1
        players[current].inJail = false
        players[current].jailTurns = 0
        surpriseDeck.append(Card(text: "Get Out of Jail Free. Keep this card until you need it.", action: .getOutOfJail))
        addLog("\(players[current].name) uses a Get Out of Jail Free card.")
        Haptics.tap()
    }

    // MARK: Auction

    private func startAuction(for index: Int) {
        var order: [Int] = []
        for k in 1...players.count {
            let i = (current + k) % players.count
            if !players[i].bankrupt { order.append(i) }
        }
        auction = Auction(index: index, active: order)
        setPhase(.auction)
    }

    func auctionBid(_ increment: Int) {
        guard phase == .auction, var a = auction, !a.active.isEmpty else { return }
        let bidder = a.active[a.turn]
        let newBid = a.bid + increment
        guard players[bidder].money >= newBid else { return }
        a.bid = newBid
        a.highBidder = bidder
        a.turn = (a.turn + 1) % a.active.count
        auction = a
        addLog("\(players[bidder].name) bids $\(newBid).")
        Haptics.tap()
        continueAuction()
    }

    func auctionPass() {
        guard phase == .auction, var a = auction, !a.active.isEmpty else { return }
        let bidder = a.active[a.turn]
        a.active.remove(at: a.turn)
        addLog("\(players[bidder].name) passes.")
        a.turn = a.active.isEmpty ? 0 : a.turn % a.active.count
        auction = a
        continueAuction()
    }

    private func continueAuction() {
        guard let a = auction else { return }
        if a.active.isEmpty {
            addLog("Nobody bought \(board[a.index].name). It stays with the bank.")
            finishAuction()
            return
        }
        if a.active.count == 1, let high = a.highBidder, high == a.active[0] {
            players[high].money -= a.bid
            owner[a.index] = high
            addLog("\(players[high].name) wins \(board[a.index].name) for $\(a.bid).")
            Haptics.success()
            finishAuction()
            return
        }
        setPhase(.auction)
    }

    private func finishAuction() {
        auction = nil
        settleTurn()
    }

    // MARK: Money, debt and bankruptcy

    @discardableResult
    private func charge(_ pi: Int, _ amount: Int, to creditor: Int?) -> Bool {
        guard amount > 0 else { return true }
        if players[pi].money < amount { liquidate(pi, needing: amount) }
        if players[pi].money >= amount {
            players[pi].money -= amount
            if let c = creditor { players[c].money += amount }
            return true
        }
        declareBankrupt(pi, creditor: creditor)
        return false
    }

    /// Automatically sells buildings and mortgages properties until the debt can be paid.
    private func liquidate(_ pi: Int, needing amount: Int) {
        var raised = false
        while players[pi].money < amount {
            let candidates = properties(of: pi).filter { houses[$0] > 0 }
            guard let idx = candidates.max(by: { houses[$0] < houses[$1] }),
                  let g = board[idx].group else { break }
            houses[idx] -= 1
            players[pi].money += g.houseCost / 2
            raised = true
        }
        while players[pi].money < amount {
            guard let idx = properties(of: pi).first(where: { !mortgaged[$0] && houses[$0] == 0 }) else { break }
            mortgaged[idx] = true
            players[pi].money += board[idx].mortgageValue
            raised = true
        }
        if raised {
            addLog("\(players[pi].name) had to sell buildings or mortgage properties to pay a debt.")
            Haptics.warning()
        }
    }

    private func declareBankrupt(_ pi: Int, creditor: Int?) {
        let name = players[pi].name
        let leftover = max(players[pi].money, 0)
        if let c = creditor {
            players[c].money += leftover
            players[c].getOutCards += players[pi].getOutCards
            addLog("\(name) is bankrupt! All assets go to \(players[c].name).")
        } else {
            addLog("\(name) is bankrupt to the bank!")
        }
        for i in 0..<40 where owner[i] == pi {
            houses[i] = 0
            if let c = creditor {
                owner[i] = c
            } else {
                owner[i] = nil
                mortgaged[i] = false
            }
        }
        players[pi].money = 0
        players[pi].getOutCards = 0
        players[pi].inJail = false
        players[pi].bankrupt = true
        Haptics.heavy()
        updateWinner()
    }

    private func updateWinner() {
        let alive = players.filter { !$0.bankrupt }
        if alive.count == 1, let w = alive.first {
            winner = w.id
            phase = .gameOver
            isBusy = false
            auction = nil
            addLog("\(w.name) wins the game!")
            Haptics.success()
        }
    }

    // MARK: Building and mortgages

    func canManage(_ index: Int) -> Bool {
        !isBusy
            && (phase == .needsRoll || phase == .postMove)
            && !players[current].isAI
            && owner[index] == current
    }

    func buildAllowed(_ index: Int, player pi: Int) -> Bool {
        guard owner[index] == pi, let g = board[index].group else { return false }
        let group = groupIndices(g)
        guard group.allSatisfy({ owner[$0] == pi && !mortgaged[$0] }) else { return false }
        guard houses[index] < 5 else { return false }
        let minHouses = group.map { houses[$0] }.min() ?? 0
        guard houses[index] == minHouses else { return false }
        return players[pi].money >= g.houseCost
    }

    func sellAllowed(_ index: Int, player pi: Int) -> Bool {
        guard owner[index] == pi, let g = board[index].group, houses[index] > 0 else { return false }
        let maxHouses = groupIndices(g).map { houses[$0] }.max() ?? 0
        return houses[index] == maxHouses
    }

    func mortgageAllowed(_ index: Int, player pi: Int) -> Bool {
        guard owner[index] == pi, !mortgaged[index], board[index].isBuyable else { return false }
        if let g = board[index].group {
            return groupIndices(g).allSatisfy { houses[$0] == 0 }
        }
        return true
    }

    func unmortgageCost(_ index: Int) -> Int {
        (board[index].mortgageValue * 11 + 9) / 10
    }

    func unmortgageAllowed(_ index: Int, player pi: Int) -> Bool {
        owner[index] == pi && mortgaged[index] && players[pi].money >= unmortgageCost(index)
    }

    func buildHouse(_ index: Int) {
        guard buildAllowed(index, player: current), let g = board[index].group else { return }
        players[current].money -= g.houseCost
        houses[index] += 1
        let what = houses[index] == 5 ? "a hotel" : "a house"
        addLog("\(players[current].name) built \(what) in \(board[index].name).")
        Haptics.success()
    }

    func sellHouse(_ index: Int) {
        guard sellAllowed(index, player: current), let g = board[index].group else { return }
        players[current].money += g.houseCost / 2
        houses[index] -= 1
        addLog("\(players[current].name) sold a building in \(board[index].name).")
        Haptics.tap()
    }

    func mortgage(_ index: Int) {
        guard mortgageAllowed(index, player: current) else { return }
        mortgaged[index] = true
        players[current].money += board[index].mortgageValue
        addLog("\(players[current].name) mortgaged \(board[index].name).")
        Haptics.tap()
    }

    func unmortgage(_ index: Int) {
        guard unmortgageAllowed(index, player: current) else { return }
        players[current].money -= unmortgageCost(index)
        mortgaged[index] = false
        addLog("\(players[current].name) paid off the mortgage on \(board[index].name).")
        Haptics.tap()
    }

    // MARK: Computer players

    private func scheduleAI(after seconds: Double = 0.9) {
        aiToken += 1
        let token = aiToken
        Task { [weak self] in
            try? await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
            guard let self, self.aiToken == token else { return }
            self.aiStep()
        }
    }

    private func aiStep() {
        if isBusy {
            scheduleAI(after: 0.5)
            return
        }
        switch phase {
        case .needsRoll:
            guard players[current].isAI else { return }
            if players[current].inJail {
                if players[current].getOutCards > 0 {
                    useJailCard()
                } else if players[current].money > 500 {
                    payJailFine()
                }
            }
            rollDice()
        case .decideBuy:
            guard players[current].isAI else { return }
            if aiWantsToBuy(players[current].position) {
                buyCurrent()
            } else {
                declineBuy()
            }
        case .postMove:
            guard players[current].isAI else { return }
            aiManage()
            endTurn()
        case .auction:
            aiAuctionStep()
        case .gameOver:
            break
        }
    }

    private func aiWantsToBuy(_ index: Int) -> Bool {
        let pi = current
        let sq = board[index]
        let money = players[pi].money
        guard money >= sq.price else { return false }
        if money - sq.price >= 150 { return true }
        if sq.kind == .railroad { return money - sq.price >= 50 }
        if let g = sq.group {
            let mates = groupIndices(g).filter { $0 != index }
            if mates.allSatisfy({ owner[$0] == pi }) { return true }
        }
        return false
    }

    private func aiValue(of index: Int, for pi: Int) -> Int {
        let sq = board[index]
        var value = Double(sq.price)
        if let g = sq.group {
            let mates = groupIndices(g).filter { $0 != index }
            if mates.allSatisfy({ owner[$0] == pi }) {
                value *= 1.8
            } else if mates.contains(where: { owner[$0] == pi }) {
                value *= 1.25
            }
        } else if sq.kind == .railroad {
            value *= 1.2
        }
        return Int(value * Double.random(in: 0.8...1.15))
    }

    private func aiAuctionStep() {
        guard phase == .auction, let a = auction, !a.active.isEmpty else { return }
        let bidder = a.active[a.turn]
        guard players[bidder].isAI else { return }
        let cap = min(aiValue(of: a.index, for: bidder), players[bidder].money)
        let room = cap - a.bid
        if room >= 10 && a.highBidder != bidder {
            let step = max(10, (room / 3 / 10) * 10)
            auctionBid(min(step, (room / 10) * 10))
        } else {
            auctionPass()
        }
    }

    private func aiManage() {
        let pi = current
        for idx in properties(of: pi) where mortgaged[idx] {
            if players[pi].money > unmortgageCost(idx) + 400 { unmortgage(idx) }
        }
        for _ in 0..<12 {
            var built = false
            for idx in properties(of: pi) {
                let cost = board[idx].group?.houseCost ?? 0
                if buildAllowed(idx, player: pi) && players[pi].money - cost >= 250 {
                    buildHouse(idx)
                    built = true
                    break
                }
            }
            if !built { break }
        }
    }
}

// MARK: - Shared Styles

struct BigButtonStyle: ButtonStyle {
    var tint: Color = .blue
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 13)
            .background(tint.opacity(isEnabled ? (configuration.isPressed ? 0.75 : 1.0) : 0.35), in: RoundedRectangle(cornerRadius: 14))
            .foregroundStyle(Color.white)
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

// MARK: - Root

struct ContentView: View {
    @State private var engine: GameEngine?

    var body: some View {
        Group {
            if let engine {
                GameView(engine: engine) { self.engine = nil }
            } else {
                SetupView { players in
                    engine = GameEngine(players: players)
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

// MARK: - Setup Screen

struct SetupView: View {
    let onStart: ([Player]) -> Void

    @State private var count = 2
    @State private var names = ["You", "Marco", "Giulia", "Luca"]
    @State private var aiFlags = [false, true, true, true]
    @State private var tokens = ["🚗", "🎩", "🐶", "🍕"]
    private let tokenChoices = ["🚗", "🎩", "🐶", "🍕", "🚢", "🐱", "🛵", "🦄", "🚀", "🎸"]

    private var hasDuplicateTokens: Bool {
        Set(tokens.prefix(count)).count != count
    }

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()
            ScrollView {
                VStack(spacing: 22) {
                    VStack(spacing: 6) {
                        Text("🎲").font(.system(size: 64))
                        Text("EMPIRE TYCOON")
                            .font(.system(size: 34, weight: .black, design: .rounded))
                            .foregroundStyle(Theme.gold)
                        Text("Buy cities. Build hotels. Bankrupt your friends.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 30)

                    VStack(alignment: .leading, spacing: 14) {
                        Text("Players").font(.headline)
                        Picker("Players", selection: $count) {
                            ForEach(2...4, id: \.self) { n in
                                Text("\(n) players").tag(n)
                            }
                        }
                        .pickerStyle(.segmented)

                        ForEach(0..<count, id: \.self) { i in
                            playerRow(i)
                        }

                        if hasDuplicateTokens {
                            Text("Each player needs a different token.")
                                .font(.caption)
                                .foregroundStyle(Color.orange)
                        }
                    }
                    .padding()
                    .background(Theme.card, in: RoundedRectangle(cornerRadius: 18))

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Rules in short").font(.headline)
                        Text("Everyone starts with $1500 and collects $200 passing GO. Buy properties, collect rent, build houses once you own a full color set, and use the auction when someone passes on a property. Last player standing wins.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Theme.card, in: RoundedRectangle(cornerRadius: 18))

                    Button {
                        startGame()
                    } label: {
                        Text("Start Game")
                    }
                    .buttonStyle(BigButtonStyle(tint: .green))
                    .disabled(hasDuplicateTokens)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 30)
            }
        }
    }

    private func playerRow(_ i: Int) -> some View {
        HStack(spacing: 10) {
            Menu {
                ForEach(tokenChoices, id: \.self) { t in
                    Button(t) { tokens[i] = t }
                }
            } label: {
                Text(tokens[i])
                    .font(.system(size: 30))
                    .frame(width: 52, height: 52)
                    .background(Player.palette[i % 4].opacity(0.35), in: Circle())
            }

            TextField("Name", text: $names[i])
                .textFieldStyle(.roundedBorder)

            Toggle("CPU", isOn: $aiFlags[i])
                .fixedSize()
        }
    }

    private func startGame() {
        var players: [Player] = []
        for i in 0..<count {
            let trimmed = names[i].trimmingCharacters(in: .whitespacesAndNewlines)
            let name = trimmed.isEmpty ? "Player \(i + 1)" : trimmed
            players.append(Player(id: i, name: name, token: tokens[i], isAI: aiFlags[i]))
        }
        onStart(players)
    }
}

// MARK: - Game Screen

struct GameView: View {
    @ObservedObject var engine: GameEngine
    let onQuit: () -> Void

    @State private var selected: SquareSelection?
    @State private var tab = 0
    @State private var viewing = 0
    @State private var showQuit = false

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 10) {
                    header
                    playerStrip
                    BoardView(engine: engine) { index in
                        selected = SquareSelection(id: index)
                    }
                    ActionPanel(engine: engine)
                    bottomTabs
                }
                .padding(.horizontal, 8)
                .padding(.bottom, 24)
            }

            if let card = engine.cardPopup {
                CardPopupView(card: card)
                    .transition(.scale.combined(with: .opacity))
                    .zIndex(2)
            }

            if engine.phase == .gameOver, let w = engine.winner {
                WinnerOverlay(engine: engine, winnerID: w, onQuit: onQuit)
                    .zIndex(3)
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: engine.cardPopup?.id)
        .sheet(item: $selected) { sel in
            SquareDetailView(engine: engine, index: sel.id)
        }
        .confirmationDialog("Leave this game?", isPresented: $showQuit, titleVisibility: .visible) {
            Button("Quit to menu", role: .destructive) { onQuit() }
            Button("Keep playing", role: .cancel) {}
        }
        .onChange(of: engine.current) { _, newValue in
            viewing = newValue
        }
    }

    private var header: some View {
        HStack {
            Text("EMPIRE TYCOON")
                .font(.system(size: 18, weight: .black, design: .rounded))
                .foregroundStyle(Theme.gold)
            Spacer()
            Button {
                showQuit = true
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, 4)
        .padding(.top, 4)
    }

    private var playerStrip: some View {
        HStack(spacing: 6) {
            ForEach(engine.players) { p in
                PlayerChip(player: p, isCurrent: p.id == engine.current, isViewing: p.id == viewing)
                    .onTapGesture {
                        viewing = p.id
                        tab = 1
                    }
            }
        }
    }

    private var bottomTabs: some View {
        VStack(spacing: 10) {
            Picker("", selection: $tab) {
                Text("Game log").tag(0)
                Text("Properties").tag(1)
            }
            .pickerStyle(.segmented)

            if tab == 0 {
                logView
            } else {
                propertiesView
            }
        }
        .padding(12)
        .background(Theme.card, in: RoundedRectangle(cornerRadius: 16))
    }

    private var logView: some View {
        VStack(alignment: .leading, spacing: 6) {
            ForEach(Array(engine.log.prefix(10).enumerated()), id: \.offset) { offset, entry in
                Text(entry.text)
                    .font(.footnote)
                    .foregroundStyle(offset == 0 ? Color.white : Color.white.opacity(0.6))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    private var propertiesView: some View {
        let owned = engine.properties(of: viewing)
        return VStack(spacing: 6) {
            Text("\(engine.players[viewing].name)'s properties (tap a player above to switch)")
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
            if owned.isEmpty {
                Text("No properties yet.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .padding(.vertical, 8)
            }
            ForEach(owned, id: \.self) { idx in
                propertyRow(idx)
            }
        }
    }

    private func propertyRow(_ idx: Int) -> some View {
        let sq = engine.board[idx]
        return Button {
            selected = SquareSelection(id: idx)
        } label: {
            HStack(spacing: 10) {
                RoundedRectangle(cornerRadius: 3)
                    .fill(sq.group?.color ?? Color.gray)
                    .frame(width: 10, height: 28)
                VStack(alignment: .leading, spacing: 1) {
                    Text(sq.name).font(.subheadline.bold())
                    Text(statusText(idx)).font(.caption).foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(8)
            .background(Color.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 10))
        }
        .buttonStyle(.plain)
    }

    private func statusText(_ idx: Int) -> String {
        if engine.mortgaged[idx] { return "Mortgaged" }
        let h = engine.houses[idx]
        if h == 5 { return "Hotel" }
        if h > 0 { return h == 1 ? "1 house" : "\(h) houses" }
        return "Rent $\(engine.rent(at: idx))"
    }
}

// MARK: - Player Chip

struct PlayerChip: View {
    let player: Player
    let isCurrent: Bool
    let isViewing: Bool

    var body: some View {
        VStack(spacing: 2) {
            HStack(spacing: 4) {
                Text(player.token).font(.title3)
                Text(player.name)
                    .font(.caption.bold())
                    .lineLimit(1)
            }
            Text(player.bankrupt ? "Bankrupt" : "$\(player.money)")
                .font(.subheadline.monospacedDigit().bold())
                .contentTransition(.numericText())
            Text(player.inJail ? "🔒 In jail" : (player.isAI ? "CPU" : "Human"))
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 4)
        .frame(maxWidth: .infinity)
        .background(RoundedRectangle(cornerRadius: 12).fill(player.color.opacity(isCurrent ? 0.55 : 0.18)))
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .stroke(isCurrent ? Color.white : (isViewing ? player.color : Color.clear), lineWidth: 2)
        }
        .opacity(player.bankrupt ? 0.4 : 1.0)
        .animation(.default, value: player.money)
    }
}

// MARK: - Board

struct BoardView: View {
    @ObservedObject var engine: GameEngine
    let onSelect: (Int) -> Void

    var body: some View {
        Color.clear
            .aspectRatio(1, contentMode: .fit)
            .overlay {
                GeometryReader { geo in
                    let side = min(geo.size.width, geo.size.height)
                    let cell = side / 11
                    ZStack(alignment: .topLeading) {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(red: 0.78, green: 0.89, blue: 0.80))

                        BoardCenter(engine: engine)
                            .frame(width: cell * 9, height: cell * 9)
                            .offset(x: cell, y: cell)

                        ForEach(engine.board) { sq in
                            let pos = Board.gridPosition(sq.id)
                            TileView(
                                square: sq,
                                cell: cell,
                                ownerToken: ownerToken(sq.id),
                                houseCount: engine.houses[sq.id],
                                isMortgaged: engine.mortgaged[sq.id],
                                isHighlighted: engine.players[engine.current].position == sq.id
                            )
                            .frame(width: cell, height: cell)
                            .contentShape(Rectangle())
                            .onTapGesture { onSelect(sq.id) }
                            .offset(x: CGFloat(pos.col) * cell, y: CGFloat(pos.row) * cell)
                        }

                        ForEach(engine.players) { p in
                            if !p.bankrupt {
                                tokenView(p, cell: cell)
                            }
                        }
                    }
                    .frame(width: side, height: side)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .shadow(color: Color.black.opacity(0.4), radius: 8, y: 4)
    }

    private func ownerToken(_ index: Int) -> String? {
        guard let o = engine.owner[index] else { return nil }
        return engine.players[o].token
    }

    private func tokenView(_ p: Player, cell: CGFloat) -> some View {
        let pos = Board.gridPosition(p.position)
        let offsets: [(CGFloat, CGFloat)] = [(-0.2, -0.2), (0.2, -0.2), (-0.2, 0.2), (0.2, 0.2)]
        let o = offsets[p.id % 4]
        return ZStack {
            Circle()
                .fill(p.color)
                .frame(width: cell * 0.56, height: cell * 0.56)
            Text(p.token)
                .font(.system(size: cell * 0.36))
        }
        .shadow(color: Color.black.opacity(0.5), radius: 2, y: 1)
        .frame(width: cell, height: cell)
        .offset(x: (CGFloat(pos.col) + o.0) * cell, y: (CGFloat(pos.row) + o.1) * cell)
        .animation(.easeInOut(duration: 0.14), value: p.position)
        .allowsHitTesting(false)
    }
}

struct BoardCenter: View {
    @ObservedObject var engine: GameEngine

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(
                    LinearGradient(
                        colors: [Color(red: 0.07, green: 0.20, blue: 0.35), Color(red: 0.04, green: 0.10, blue: 0.22)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            VStack(spacing: 14) {
                Text("EMPIRE\nTYCOON")
                    .font(.system(size: 30, weight: .black, design: .rounded))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Theme.gold)
                    .rotationEffect(.degrees(-6))

                HStack(spacing: 16) {
                    DieView(value: engine.die1, rolling: engine.isRolling)
                    DieView(value: engine.die2, rolling: engine.isRolling)
                }

                Text(engine.log.first?.text ?? "")
                    .font(.caption)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
                    .foregroundStyle(Color.white.opacity(0.85))
                    .padding(.horizontal, 12)
            }
        }
        .padding(2)
    }
}

struct DieView: View {
    let value: Int
    let rolling: Bool

    private let pips: [Int: [Int]] = [
        1: [4],
        2: [0, 8],
        3: [0, 4, 8],
        4: [0, 2, 6, 8],
        5: [0, 2, 4, 6, 8],
        6: [0, 2, 3, 5, 6, 8]
    ]

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.4), radius: 3, y: 2)
            VStack(spacing: 4) {
                ForEach(0..<3, id: \.self) { r in
                    HStack(spacing: 4) {
                        ForEach(0..<3, id: \.self) { c in
                            Circle()
                                .fill(isPip(r * 3 + c) ? Color.black : Color.clear)
                                .frame(width: 9, height: 9)
                        }
                    }
                }
            }
        }
        .frame(width: 56, height: 56)
        .rotationEffect(.degrees(rolling ? Double.random(in: -25...25) : 0))
        .animation(.easeInOut(duration: 0.08), value: value)
    }

    private func isPip(_ index: Int) -> Bool {
        (pips[value] ?? []).contains(index)
    }
}

// MARK: - Tile

struct TileView: View {
    let square: Square
    let cell: CGFloat
    let ownerToken: String?
    let houseCount: Int
    let isMortgaged: Bool
    let isHighlighted: Bool

    var body: some View {
        ZStack {
            Rectangle().fill(Color(red: 0.97, green: 0.97, blue: 0.93))
            tileContent
            if isMortgaged {
                Rectangle().fill(Color.gray.opacity(0.7))
                Text("M")
                    .font(.system(size: cell * 0.4, weight: .black))
                    .foregroundStyle(Color.white)
            }
        }
        .overlay(alignment: .bottomTrailing) {
            if let t = ownerToken {
                Text(t)
                    .font(.system(size: cell * 0.3))
                    .padding(0.5)
            }
        }
        .overlay {
            Rectangle()
                .stroke(isHighlighted ? Color.yellow : Color.black.opacity(0.4), lineWidth: isHighlighted ? 2 : 0.5)
        }
        .foregroundStyle(Color.black)
        .clipped()
    }

    @ViewBuilder
    private var tileContent: some View {
        switch square.kind {
        case .property(let g):
            propertyTile(g)
        case .go:
            VStack(spacing: 0) {
                Text("GO")
                    .font(.system(size: cell * 0.42, weight: .black))
                    .foregroundStyle(Color.red)
                Text("collect $200")
                    .font(.system(size: cell * 0.14, weight: .semibold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
            }
        default:
            VStack(spacing: 0) {
                Text(icon).font(.system(size: cell * 0.42))
                Text(shortName)
                    .font(.system(size: cell * 0.17, weight: .semibold))
                    .lineLimit(2)
                    .minimumScaleFactor(0.5)
                    .multilineTextAlignment(.center)
            }
            .padding(1)
        }
    }

    @ViewBuilder
    private func propertyTile(_ g: ColorGroup) -> some View {
        let band = cell * 0.28
        let edge = Board.edge(of: square.id)
        let vertical = (edge == .left || edge == .right)
        let bandView = ZStack {
            Rectangle().fill(g.color)
            buildingsView(vertical: vertical)
        }
        let label = Text(square.name)
            .font(.system(size: cell * 0.19, weight: .semibold))
            .lineLimit(2)
            .minimumScaleFactor(0.5)
            .multilineTextAlignment(.center)
            .padding(1)
        switch edge {
        case .left:
            HStack(spacing: 0) {
                label.frame(maxWidth: .infinity, maxHeight: .infinity)
                bandView.frame(width: band)
            }
        case .right:
            HStack(spacing: 0) {
                bandView.frame(width: band)
                label.frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        case .top:
            VStack(spacing: 0) {
                label.frame(maxWidth: .infinity, maxHeight: .infinity)
                bandView.frame(height: band)
            }
        default:
            VStack(spacing: 0) {
                bandView.frame(height: band)
                label.frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }

    @ViewBuilder
    private func buildingsView(vertical: Bool) -> some View {
        if houseCount > 0 {
            let isHotel = houseCount == 5
            let n = isHotel ? 1 : houseCount
            let size = cell * 0.16
            let tint: Color = isHotel ? Color.red : Color.green
            if vertical {
                VStack(spacing: 1) {
                    ForEach(0..<n, id: \.self) { _ in
                        RoundedRectangle(cornerRadius: 1).fill(tint).frame(width: size, height: isHotel ? size * 1.8 : size)
                    }
                }
            } else {
                HStack(spacing: 1) {
                    ForEach(0..<n, id: \.self) { _ in
                        RoundedRectangle(cornerRadius: 1).fill(tint).frame(width: isHotel ? size * 1.8 : size, height: size)
                    }
                }
            }
        }
    }

    private var icon: String {
        switch square.kind {
        case .railroad: return "🚉"
        case .utility: return square.name.hasPrefix("Power") ? "💡" : "🚰"
        case .surprise: return "❓"
        case .treasure: return "🎁"
        case .tax: return "💸"
        case .jail: return "🔒"
        case .restStop: return "☕️"
        case .goToJail: return "👮"
        default: return ""
        }
    }

    private var shortName: String {
        switch square.kind {
        case .tax(let a): return "Tax $\(a)"
        default: return square.name
        }
    }
}

// MARK: - Action Panel

struct ActionPanel: View {
    @ObservedObject var engine: GameEngine

    private var player: Player { engine.players[engine.current] }

    private var aiIsActing: Bool {
        if engine.phase == .auction, let a = engine.auction, !a.active.isEmpty {
            return engine.players[a.active[a.turn]].isAI
        }
        return player.isAI && engine.phase != .gameOver
    }

    private var subtitle: String {
        switch engine.phase {
        case .needsRoll:
            return player.inJail ? "In jail, attempt \(player.jailTurns + 1) of 3" : "Roll the dice"
        case .decideBuy:
            return "Buy \(engine.board[player.position].name)?"
        case .postMove:
            return "Manage properties, then end your turn"
        case .auction:
            return "Auction in progress"
        case .gameOver:
            return "Game over"
        }
    }

    var body: some View {
        VStack(spacing: 10) {
            HStack(spacing: 10) {
                Text(player.token).font(.largeTitle)
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(player.name)'s turn").font(.headline)
                    Text(subtitle).font(.caption).foregroundStyle(.secondary)
                }
                Spacer()
                if aiIsActing { ProgressView() }
            }
            controls
        }
        .padding(12)
        .background(Theme.card, in: RoundedRectangle(cornerRadius: 16))
    }

    @ViewBuilder
    private var controls: some View {
        switch engine.phase {
        case .needsRoll:
            if !player.isAI { rollControls }
        case .decideBuy:
            if !player.isAI { buyControls }
        case .postMove:
            if !player.isAI {
                VStack(spacing: 8) {
                    Text("Tap any tile or one of your properties to build or mortgage.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                    Button {
                        engine.endTurn()
                    } label: {
                        Text("End Turn")
                    }
                    .buttonStyle(BigButtonStyle(tint: .indigo))
                    .disabled(engine.isBusy)
                }
            }
        case .auction:
            AuctionPanel(engine: engine)
        case .gameOver:
            EmptyView()
        }
    }

    private var rollControls: some View {
        VStack(spacing: 8) {
            Button {
                engine.rollDice()
            } label: {
                Label(player.inJail ? "Roll for doubles" : "Roll dice", systemImage: "die.face.5.fill")
            }
            .buttonStyle(BigButtonStyle(tint: .green))
            .disabled(engine.isBusy)

            if player.inJail {
                HStack(spacing: 8) {
                    Button {
                        engine.payJailFine()
                    } label: {
                        Text("Pay $50")
                    }
                    .buttonStyle(BigButtonStyle(tint: .orange))
                    .disabled(player.money < 50 || engine.isBusy)

                    if player.getOutCards > 0 {
                        Button {
                            engine.useJailCard()
                        } label: {
                            Text("Use card")
                        }
                        .buttonStyle(BigButtonStyle(tint: .purple))
                        .disabled(engine.isBusy)
                    }
                }
            }
        }
    }

    private var buyControls: some View {
        let sq = engine.board[player.position]
        return VStack(spacing: 8) {
            HStack(spacing: 10) {
                RoundedRectangle(cornerRadius: 3)
                    .fill(sq.group?.color ?? Color.gray)
                    .frame(width: 10, height: 28)
                Text(sq.name).font(.headline)
                Spacer()
                Text("$\(sq.price)").font(.title3.bold())
            }
            if player.money < sq.price {
                Text("Not enough cash to buy. Send it to auction.")
                    .font(.caption)
                    .foregroundStyle(Color.orange)
            }
            HStack(spacing: 10) {
                Button {
                    engine.buyCurrent()
                } label: {
                    Text("Buy")
                }
                .buttonStyle(BigButtonStyle(tint: .green))
                .disabled(player.money < sq.price)

                Button {
                    engine.declineBuy()
                } label: {
                    Text("Auction")
                }
                .buttonStyle(BigButtonStyle(tint: .orange))
            }
        }
    }
}

struct AuctionPanel: View {
    @ObservedObject var engine: GameEngine

    var body: some View {
        if let a = engine.auction, !a.active.isEmpty {
            let bidder = engine.players[a.active[a.turn]]
            VStack(spacing: 8) {
                HStack {
                    Text("🔨 \(engine.board[a.index].name)")
                        .font(.headline)
                    Spacer()
                    Text("Price $\(engine.board[a.index].price)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                HStack {
                    Text("Current bid: $\(a.bid)")
                        .font(.subheadline.bold())
                    if let high = a.highBidder {
                        Text("by \(engine.players[high].token) \(engine.players[high].name)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                }
                if bidder.isAI {
                    Text("\(bidder.token) \(bidder.name) is thinking...")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } else {
                    Text("\(bidder.token) \(bidder.name), your move (cash $\(bidder.money))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    HStack(spacing: 8) {
                        bidButton(10, bidder: bidder, bid: a.bid)
                        bidButton(50, bidder: bidder, bid: a.bid)
                        bidButton(100, bidder: bidder, bid: a.bid)
                    }
                    Button {
                        engine.auctionPass()
                    } label: {
                        Text("Pass")
                    }
                    .buttonStyle(BigButtonStyle(tint: .red))
                }
            }
        }
    }

    private func bidButton(_ amount: Int, bidder: Player, bid: Int) -> some View {
        Button {
            engine.auctionBid(amount)
        } label: {
            Text("+$\(amount)")
        }
        .buttonStyle(BigButtonStyle(tint: .green))
        .disabled(bidder.money < bid + amount)
    }
}

// MARK: - Square Detail Sheet

struct SquareDetailView: View {
    @ObservedObject var engine: GameEngine
    let index: Int

    private let rentLabels = ["Rent", "With 1 house", "With 2 houses", "With 3 houses", "With 4 houses", "With hotel"]

    private var sq: Square { engine.board[index] }

    var body: some View {
        ScrollView {
            VStack(spacing: 14) {
                banner

                if sq.isBuyable {
                    VStack(spacing: 8) {
                        row("Price", "$\(sq.price)")
                        row("Mortgage value", "$\(sq.mortgageValue)")
                        if let g = sq.group { row("House cost", "$\(g.houseCost)") }
                        row("Owner", ownerText)
                        if engine.mortgaged[index] { row("Status", "Mortgaged") }
                        if engine.houses[index] > 0 {
                            row("Buildings", engine.houses[index] == 5 ? "Hotel" : "\(engine.houses[index]) house(s)")
                        }
                    }
                    .padding()
                    .background(Theme.card, in: RoundedRectangle(cornerRadius: 14))

                    rentTable
                } else {
                    Text(blurb)
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .padding()
                }

                if engine.canManage(index) {
                    manageSection
                }
            }
            .padding()
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }

    private var banner: some View {
        let fill: Color = sq.group?.color ?? Color(red: 0.25, green: 0.30, blue: 0.45)
        let darkText = (sq.group == ColorGroup.yellow || sq.group == ColorGroup.lightBlue)
        return VStack(spacing: 4) {
            Text(sq.name).font(.title2.bold())
            Text(subtitle).font(.caption)
        }
        .foregroundStyle(darkText ? Color.black : Color.white)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(fill, in: RoundedRectangle(cornerRadius: 14))
    }

    private var subtitle: String {
        switch sq.kind {
        case .property: return "City"
        case .railroad: return "Station"
        case .utility: return "Utility"
        case .tax: return "Tax"
        default: return "Special square"
        }
    }

    private var blurb: String {
        switch sq.kind {
        case .go: return "Collect $200 every time you pass or land on GO."
        case .jail: return "Just visiting, unless you were sent here. Leave by rolling doubles, paying $50, or using a Get Out of Jail Free card. After 3 failed tries you pay $50."
        case .restStop: return "Take a breather. Nothing happens here."
        case .goToJail: return "Land here and you go straight to Jail."
        case .surprise: return "Draw a Surprise card."
        case .treasure: return "Draw a Treasure card."
        case .tax(let a): return "Pay $\(a) to the bank."
        default: return ""
        }
    }

    private var ownerText: String {
        if let o = engine.owner[index] {
            return "\(engine.players[o].token) \(engine.players[o].name)"
        }
        return "Bank"
    }

    @ViewBuilder
    private var rentTable: some View {
        VStack(spacing: 6) {
            if case .property = sq.kind {
                ForEach(0..<sq.rents.count, id: \.self) { i in
                    row(rentLabels[i], "$\(sq.rents[i])")
                }
                Text("Rent doubles when one player owns the whole color set.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else if sq.kind == .railroad {
                row("1 station owned", "$25")
                row("2 stations owned", "$50")
                row("3 stations owned", "$100")
                row("4 stations owned", "$200")
            } else if sq.kind == .utility {
                Text("Rent is 4 times the dice roll with one utility, and 10 times with both.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(Theme.card, in: RoundedRectangle(cornerRadius: 14))
    }

    private var manageSection: some View {
        VStack(spacing: 10) {
            Text("Manage").font(.headline)

            if let g = sq.group {
                HStack(spacing: 10) {
                    Button {
                        engine.buildHouse(index)
                    } label: {
                        Text(engine.houses[index] == 4 ? "Hotel -$\(g.houseCost)" : "House -$\(g.houseCost)")
                    }
                    .buttonStyle(BigButtonStyle(tint: .green))
                    .disabled(!engine.buildAllowed(index, player: engine.current))

                    Button {
                        engine.sellHouse(index)
                    } label: {
                        Text("Sell +$\(g.houseCost / 2)")
                    }
                    .buttonStyle(BigButtonStyle(tint: .orange))
                    .disabled(!engine.sellAllowed(index, player: engine.current))
                }
                if !engine.ownsFullGroup(engine.current, g) {
                    Text("Own every city of this color to build.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            HStack(spacing: 10) {
                Button {
                    engine.mortgage(index)
                } label: {
                    Text("Mortgage +$\(sq.mortgageValue)")
                }
                .buttonStyle(BigButtonStyle(tint: .purple))
                .disabled(!engine.mortgageAllowed(index, player: engine.current))

                Button {
                    engine.unmortgage(index)
                } label: {
                    Text("Unmortgage -$\(engine.unmortgageCost(index))")
                }
                .buttonStyle(BigButtonStyle(tint: .teal))
                .disabled(!engine.unmortgageAllowed(index, player: engine.current))
            }
        }
    }

    private func row(_ title: String, _ value: String) -> some View {
        HStack {
            Text(title).foregroundStyle(.secondary)
            Spacer()
            Text(value).bold()
        }
        .font(.subheadline)
    }
}

// MARK: - Overlays

struct CardPopupView: View {
    let card: CardPopup

    var body: some View {
        VStack(spacing: 12) {
            Text(card.isSurprise ? "❓ SURPRISE" : "🎁 TREASURE")
                .font(.headline.bold())
                .foregroundStyle(card.isSurprise ? Color.orange : Color.blue)
            Text(card.text)
                .font(.title3.weight(.semibold))
                .multilineTextAlignment(.center)
                .foregroundStyle(Color.black)
        }
        .padding(24)
        .frame(maxWidth: 310)
        .background(Color(red: 1.0, green: 0.97, blue: 0.88), in: RoundedRectangle(cornerRadius: 20))
        .shadow(color: Color.black.opacity(0.5), radius: 20)
    }
}

struct WinnerOverlay: View {
    @ObservedObject var engine: GameEngine
    let winnerID: Int
    let onQuit: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.7).ignoresSafeArea()
            VStack(spacing: 14) {
                Text("🏆").font(.system(size: 72))
                Text("\(engine.players[winnerID].name) wins!")
                    .font(.largeTitle.bold())
                    .foregroundStyle(Theme.gold)
                Text("Net worth $\(engine.netWorth(winnerID))")
                    .font(.title3)
                Button {
                    onQuit()
                } label: {
                    Text("Back to menu")
                }
                .buttonStyle(BigButtonStyle(tint: .indigo))
            }
            .padding(28)
            .background(Color(red: 0.08, green: 0.12, blue: 0.24), in: RoundedRectangle(cornerRadius: 24))
            .padding(32)
        }
    }
}

#Preview {
    ContentView()
}
