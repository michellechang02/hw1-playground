import Foundation

// Game state enums and structs
// Requirement: At least 2 structs/enums (Direction, Location, Item enums)
enum Direction {
    case north, south, east, west
}

// Requirement: At least 5 traversable locations
enum Location {
    case mainGate      // Gwanghwamun - Starting location
    case courtyard     // Geunjeongmun - Central hub
    case throneHall    // Geunjeongjeon - Requires blessed binyeo
    case library       // Gyujanggak - Contains scroll
    case garden        // Hyangwonjeong - Contains incense
    case temple        // Jagyeongjeon - Final location with 2 endings
}

// Requirement: At least 1 item that affects gameplay
// Items can be picked up and used to bless sacred places
enum Item: String {
    case binyeo = "binyeo"
    case scroll = "scroll"
    case incense = "incense"
}

// Requirement: At least 1 protocol used meaningfully
// Protocol defines behavior for places that can be blessed with items
protocol Sacred {
    var isBlessed: Bool { get set }
    mutating func bless(with item: Item) -> Bool
}

// Requirement: At least 1 struct/enum conforming to protocol
struct SacredPlace: Sacred {
    var isBlessed: Bool
    // Requirement: Non-trivial optional - requiredItem may be nil
    var requiredItem: Item?
    
    mutating func bless(with item: Item) -> Bool {
        if let required = requiredItem, required == item {
            isBlessed = true
            return true
        }
        return false
    }
}

struct GameState {
    var currentLocation: Location = .mainGate
    // Requirement: Use of arrays/dictionaries
    var inventory: [Item] = []
    var sacredPlaces: [Location: SacredPlace] = [
        .temple: SacredPlace(isBlessed: false, requiredItem: .incense),
        .throneHall: SacredPlace(isBlessed: false, requiredItem: .binyeo)
    ]
    var hasReadScroll = false  // Add this to track if scroll has been read
    var hasFoundSecret = false
    var hasBeenBanished = false
}

/// The main game implementation
struct GyeongbokgungGame: AdventureGame {
    private var state = GameState()
    
    var title: String {
        return "Secret of Gyeongbokgung Palace 🏯"
    }
    
    mutating func start(context: AdventureGameContext) {
        context.write("In the twilight of the Joseon Dynasty...")
        context.write("You stand before the mighty Gyeongbokgung Palace. 🏯")
        context.write("As a scholar seeking King Sejong's secret wisdom behind Hangul,")
        context.write("you must uncover the hidden knowledge within these sacred walls.")
        context.write("Type 'help' for available commands.")
        describeCurrentLocation(context: context)
    }
    
    private mutating func describeCurrentLocation(context: AdventureGameContext) {
        switch state.currentLocation {
        case .mainGate:
            context.write("You stand at Gwanghwamun, the main gate of Gyeongbokgung. 🚪")
            context.write("The grand entrance to the palace complex lies before you.")
            context.write("Available paths: go north to courtyard")
            
        case .courtyard:
            context.write("You are in the main courtyard, Geunjeongmun. 🏞️")
            context.write("Palace guards patrol in the distance.")
            if !state.inventory.contains(.binyeo) {
                context.write("A royal binyeo (jade hairpin) glints in the moonlight. 💎")
            }
            context.write("Available paths: go north to throne hall, go east to library, go south to main gate")
            
        case .throneHall:
            context.write("You stand in Geunjeongjeon, the majestic throne hall. 👑")
            context.write("The king's empty throne casts long shadows.")
            context.write("Available paths: go east to garden, go south to courtyard")
            
        case .library:
            context.write("You are in Gyujanggak, the royal library. 📚")
            context.write("Ancient texts line the shelves.")
            if !state.inventory.contains(.scroll) {
                context.write("A mysterious scroll catches your eye. 📜")
            }
            context.write("Available paths: go west to courtyard")
            
        case .garden:
            context.write("You walk through Hyangwonjeong garden. 🌸")
            context.write("A serene pavilion stands on an island in the pond.")
            if !state.inventory.contains(.incense) {
                context.write("Sacred incense burns nearby. 🕯️")
            }
            context.write("Available paths: go north to temple, go west to throne hall")
            
        case .temple:
            if !state.hasFoundSecret && !state.hasReadScroll && state.sacredPlaces[.temple]?.isBlessed != true {
                context.write("\nPalace guards discover your unauthorized presence in the sacred temple! 🚨")
                context.write("Without the ancient scroll's knowledge and proper temple blessing,")
                context.write("you are immediately recognized as an intruder.")
                context.write("\nYou have been banished from Gyeongbokgung Palace forever. 🚫")
                context.write("The secret of Hangul remains undiscovered...")
                state.hasBeenBanished = true
                context.endGame()
                return
            }
            
            if !state.hasFoundSecret {
                context.write("You are in Jagyeongjeon, the sacred temple. ⛩️")
                context.write("The air is thick with anticipation.")
                context.write("Ancient secrets of Hangul might be hidden here...")
                context.write("Available paths: go south to garden")
            }
        }
    }
    
    
    
    mutating func handle(input: String, context: AdventureGameContext) {
            let command = input.lowercased().trimmingCharacters(in: .whitespaces)
            
            switch command {
            case "help":
                showHelp(context: context)
            case "look":
                describeCurrentLocation(context: context)
            case "inventory":
                showInventory(context: context)
            case "north", "south", "east", "west":
                handleMovement(direction: command, context: context)
            case let str where str.hasPrefix("take "):
                let item = String(str.dropFirst(5))
                handleTakeItem(item: item, context: context)
            case let str where str.hasPrefix("use "):
                let item = String(str.dropFirst(4))
                handleUseItem(item: item, context: context)
            default:
                context.write("I don't understand that command. Type 'help' for available commands.")
            }
            
        }
    
    private func showHelp(context: AdventureGameContext) {
        context.write("Available commands:")
        context.write("- look: examine your surroundings 👀")
        context.write("- inventory: check your items 🧳")
        context.write("- north/south/east/west: move in that direction 🧭")
        context.write("- take binyeo/scroll/incense: pick up an item 🖐️")
        context.write("- use binyeo/scroll/incense: use an item 🛠️")
        context.write("- help: show this help message ℹ️")
        context.write("\nHint: You need the binyeo to enter the throne hall")
        context.write("      and both the scroll and blessed temple to win!")
    }
    
    private func showInventory(context: AdventureGameContext) {
        if state.inventory.isEmpty {
            context.write("Your inventory is empty. 👜")
        } else {
            context.write("Your inventory contains:")
            state.inventory.forEach { item in
                context.write("- \(item.rawValue) 🧳")
            }
        }
    }
    
    private mutating func handleMovement(direction: String, context: AdventureGameContext) {
        let newLocation: Location?
        
        switch (state.currentLocation, direction) {
        case (.mainGate, "north"): 
            newLocation = .courtyard
            
        case (.courtyard, "north"): 
            if !state.inventory.contains(.binyeo) {
                context.write("A mysterious force prevents your entry to the throne hall. You need the royal binyeo. 💎")
                return
            }
            if let place = state.sacredPlaces[.throneHall], !place.isBlessed {
                context.write("The throne hall requires the binyeo's blessing before entry. 🙏")
                return
            }
            newLocation = .throneHall
            
        case (.courtyard, "east"): newLocation = .library
        case (.courtyard, "south"): newLocation = .mainGate
        case (.throneHall, "east"): newLocation = .garden
        case (.throneHall, "south"): newLocation = .courtyard
        case (.library, "west"): newLocation = .courtyard
        case (.garden, "north"): newLocation = .temple
        case (.garden, "west"): newLocation = .throneHall
        case (.temple, "south"): newLocation = .garden
        default: newLocation = nil
        }
        
        if let newLoc = newLocation {
            state.currentLocation = newLoc
            describeCurrentLocation(context: context)
        } else {
            context.write("You cannot go that way. 🚫")
        }
    }
    
    private mutating func handleTakeItem(item: String, context: AdventureGameContext) {
        let itemMap = [
            "binyeo": Item.binyeo,
            "scroll": Item.scroll,
            "incense": Item.incense
        ]
        
        guard let item = itemMap[item] else {
            context.write("That's not something you can take. 🚫")
            return
        }
        
        switch (state.currentLocation, item) {
        case (.courtyard, .binyeo):
            if !state.inventory.contains(.binyeo) {
                state.inventory.append(.binyeo)
                context.write("You carefully take the royal binyeo, admiring its jade ornaments. 💎")
            } else {
                context.write("You already have the binyeo. 💎")
            }
        case (.library, .scroll):
            if !state.inventory.contains(.scroll) {
                state.inventory.append(.scroll)
                context.write("You reverently take the ancient scroll. 📜")
            } else {
                context.write("You already have the scroll. 📜")
            }
        case (.garden, .incense):
            if !state.inventory.contains(.incense) {
                state.inventory.append(.incense)
                context.write("You collect the sacred incense. 🕯️")
            } else {
                context.write("You already have the incense. 🕯️")
            }
        default:
            context.write("There's no \(item.rawValue) here to take. 🚫")
        }
    }
    
    private mutating func handleUseItem(item: String, context: AdventureGameContext) {
        guard let item = Item(rawValue: item) else {
            context.write("That's not something you can use. 🚫")
            return
        }
        
        guard state.inventory.contains(item) else {
            context.write("You don't have that item. 🚫")
            return
        }
        
        switch (state.currentLocation, item) {
        case (.courtyard, .binyeo):
            if var place = state.sacredPlaces[.throneHall], !place.isBlessed {
                if place.bless(with: item) {
                    state.sacredPlaces[.throneHall] = place
                    context.write("The throne hall resonates with the power of the binyeo! 💎")
                } else {
                    context.write("Nothing happens. 🚫")
                }
            }
        case (.temple, .incense):
            if var place = state.sacredPlaces[.temple], !place.isBlessed {
                if place.bless(with: item) {
                    state.sacredPlaces[.temple] = place
                    context.write("The temple accepts your offering! 🕯️")
                    
                    if state.hasReadScroll {
                        context.write("\nThe temple fills with a mystical light as ancient knowledge reveals itself! ✨")
                        context.write("\nYou have discovered King Sejong's hidden wisdom behind the creation of Hangul,")
                        context.write("the phonetic system for reading and writing Korean language.")
                        context.write("His revolutionary alphabet was designed to be easy to learn,")
                        context.write("allowing common people to become literate and educated.")
                        context.write("\nVictory! You have uncovered one of Korea's greatest cultural achievements! 🏆")
                        state.hasFoundSecret = true
                        context.endGame()
                    }
                } else {
                    context.write("Nothing happens. 🚫")
                }
            }
        case (_, .scroll):
            state.hasReadScroll = true
            context.write("You carefully unroll the ancient scroll. 📜")
            context.write("The text speaks of blessing sacred places with the royal binyeo and temple incense.")
            context.write("Only then will the secrets of Hangul be revealed.")
        default:
            context.write("Nothing happens. 🚫")
        }
    }
}

// Run the game
GyeongbokgungGame.run()
