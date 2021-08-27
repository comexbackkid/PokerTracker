//
//  SessionModel.swift
//  PokerTracker
//
//  Created by Christian Nachtrieb on 8/10/21.
//

import Foundation

struct PokerSession: Hashable, Identifiable {
    let id = UUID()
    let location: String
    let game: String
    let stakes: String
    let date: String
    let profit: String
    let notes: String
    let imageName: String
    let startTime: Date
    let endTime: Date
}

extension PokerSession {
    
    static func faked(
        id: UUID = UUID(),
        location: String = imageFromLocationDictionary.first!.key,
        game: String = "NL Texas Hold Em",
        stakes: String = "1/2",
        date: String = "January 1, 2021",
        profit: String = "863",
        notes: String = "Hero is UTG so we raise to $15. MP player 3! to $45, everyone else folds. I flat, in this game there’s no 4! so it’s a dead giveaway in this game. ($93) Flop is 8d6c3d. Hero checks to Villain who bets $35. Hero raises to $100, Villain thinks for a few moments and then calls. ($293) Turn is a Js. We have $240 in our stack & Villain covers, we think for about 10 seconds and jam. He tanks for a long time, asks if I’ll show, ultimately he lays it down. We find out he had TT. Did we play too aggressive?? MP limps, LJ limps, Hero on BTN makes it $15, they both call. ($48) Flop is KdKhTs. MP checks, LJ bets $10, I call, MP calls. ($78) Turn is Ac. MP checks, LJ checks, I bet $55 thinking they’re both super weak here. MP thinks for a moment and calls, LJ folds. ($188) River comes Qd. MP checks. Hero? We tank and ultimately check. MP is pissed and tables AK for a boat.",
        imageName: String = "chasers-header",
        startTime: Date = Date(),
        endTime: Date = Date().adding(minutes: 45)) -> PokerSession {
        return PokerSession(
            location: location,
            game: game,
            stakes: stakes,
            date: date,
            profit: profit,
            notes: notes,
            imageName: imageName,
            startTime: startTime,
            endTime: endTime
        )
    }

}


struct MockData {
    
    static let newSession = PokerSession.faked(startTime: Date(), endTime: Date().adding(minutes: 0))
    
    static let sampleSession = PokerSession(location: "Chaser's Poker Room",
                                            game: "NL Texas Hold Em",
                                            stakes: "1/2",
                                            date: "January 1, 2021",
                                            profit: "863",
                                            notes: "Hero is UTG so we raise to $15. MP player 3! to $45, everyone else folds. I flat, in this game there’s no 4! so it’s a dead giveaway in this game. ($93) Flop is 8d6c3d. Hero checks to Villain who bets $35. Hero raises to $100, Villain thinks for a few moments and then calls. ($293) Turn is a Js. We have $240 in our stack & Villain covers, we think for about 10 seconds and jam. He tanks for a long time, asks if I’ll show, ultimately he lays it down. We find out he had TT. Did we play too aggressive?? MP limps, LJ limps, Hero on BTN makes it $15, they both call. ($48) Flop is KdKhTs. MP checks, LJ bets $10, I call, MP calls. ($78) Turn is Ac. MP checks, LJ checks, I bet $55 thinking they’re both super weak here. MP thinks for a moment and calls, LJ folds. ($188) River comes Qd. MP checks. Hero? We tank and ultimately check. MP is pissed and tables AK for a boat.",
                                            imageName: "chasers-header",
                                            startTime: Date(),
                                            endTime: Date().adding(minutes: 45))
                                            

    static let allSessions = [
        PokerSession(location: "Chaser's Poker Room",
                     game: "NL Texas Hold Em",
                     stakes: "1/2",
                     date: "January 1, 2021",
                     profit: "300",
                     notes: "Hero is UTG so we raise to $15. MP player 3! to $45, everyone else folds. I flat, in this game there’s no 4! so it’s a dead giveaway in this game. ($93) Flop is 8d6c3d. Hero checks to Villain who bets $35. Hero raises to $100, Villain thinks for a few moments and then calls. ($293) Turn is a Js. We have $240 in our stack & Villain covers, we think for about 10 seconds and jam. He tanks for a long time, asks if I’ll show, ultimately he lays it down. We find out he had TT. Did we play too aggressive?? MP limps, LJ limps, Hero on BTN makes it $15, they both call. ($48) Flop is KdKhTs. MP checks, LJ bets $10, I call, MP calls. ($78) Turn is Ac. MP checks, LJ checks, I bet $55 thinking they’re both super weak here. MP thinks for a moment and calls, LJ folds. ($188) River comes Qd. MP checks. Hero? We tank and ultimately check. MP is pissed and tables AK for a boat.",
                     imageName: "chasers-header",
                     startTime: Date(),
                     endTime: Date()),
       
        PokerSession(location: "Encore Boston Harbor",
                     game: "NL Texas Hold Em",
                     stakes: "1/3",
                     date: "January 5, 2021",
                     profit: "225",
                     notes: "MP limps, LJ limps, Hero on BTN makes it $15, they both call. ($48) Flop is KdKhTs. MP checks, LJ bets $10, I call, MP calls. ($78) Turn is Ac. MP checks, LJ checks, I bet $55 thinking they’re both super weak here. MP thinks for a moment and calls, LJ folds. ($188) River comes Qd. MP checks. Hero? We tank and ultimately check. MP is pissed and tables AK for a boat.",
                     imageName: "encore-header",
                     startTime: Date(),
                     endTime: Date()),
        
        PokerSession(location: "Boston Billiard's Club",
                     game: "NL Texas Hold Em",
                     stakes: "1/2",
                     date: "March 8, 2021",
                     profit: "108",
                     notes: "Hero in CO, MP & LP limp I raise $15, Villain is on BTN (younger kid, stack around $550-$600) and he 3! to $45, we call. ($94) Flop is KsQh9h. I check, he bets $35, we call. ($160) Turn is Ac. I check again, Villain pauses a moment and puts in $100. We have about $320 left. Hero???",
                     imageName: "boston-billiards-header",
                     startTime: Date(),
                     endTime: Date()),
        
        PokerSession(location: "Boston Billiard's Club",
                     game: "NL Texas Hold Em",
                     stakes: "1/2", date: "June 43, 2021",
                     profit: "397",
                     notes: "MP limps, LJ limps, Hero on BTN makes it $15, they both call. ($48) Flop is KdKhTs. MP checks, LJ bets $10, I call, MP calls. ($78) Turn is Ac. MP checks, LJ checks, I bet $55 thinking they’re both super weak here. MP thinks for a moment and calls, LJ folds. ($188) River comes Qd. MP checks. Hero? We tank and ultimately check. MP is pissed and tables AK for a boat.",
                     imageName: "boston-billiards-header",
                     startTime: Date(),
                     endTime: Date()),
        
        PokerSession(location: "Chaser's Poker Room",
                     game: "NL Texas Hold Em",
                     stakes: "1/2",
                     date: "July 11, 2021",
                     profit: "119",
                     notes: "Two limpers, I raise to $12 from SB, BB folds, UTG+1 (primary villain) calls, BTN calls. ($38) Flop is QcTc4h. I check, everyone checks. Turn is a 9h. We check, UTG+1 checks, BTN bets $20. We call. UTG+1 raises to $80. BTN folds, we call. ($218) River is a 6h. I check, villain bets $140. Hero?",
                     imageName: "chasers-header",
                     startTime: Date(),
                     endTime: Date())
    ]
}

extension Date {
    func adding(minutes: Int) -> Date {
        return Calendar.current.date(byAdding: .minute, value: minutes, to: self)!
    }
}
