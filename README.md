# Secret of Gyeongbokgung Palace 🇰🇷

*For instructions, consult the [CIS 1951 website](https://www.seas.upenn.edu/~cis1951/25sp/assignments/hw/hw1).*

## Explanations

**What locations/rooms does your game have?**

1. Main Gate - Gwanghwamun, the starting location
2. Courtyard - Geunjeongmun, the central hub
3. Throne Hall - Geunjeongjeon, requires blessed binyeo
4. Library - Gyujanggak, contains scroll
5. Garden - Hyangwonjeong, contains incense
6. Temple - Jagyeongjeon, final location with 2 endings

**What items does your game have?**

1. Binyeo - A royal jade hairpin
2. Scroll - A mysterious scroll with ancient knowledge
3. Incense - Sacred incense from the garden

**Explain how your code is designed. In particular, describe how you used structs or enums, as well as protocols.**
The game's architecture is built around a robust type system using enums for Directions, Locations, and Items, providing compile-time safety and clear domain modeling. At its core, the GameState struct serves as the central data model, managing the player's current location, inventory, and sacred place states through a dictionary. The Sacred protocol defines an interface for locations that can be blessed, with the SacredPlace struct implementing this protocol to handle blessing validation and optional required items. The main game logic resides in the GyeongbokgungGame struct, which implements movement, item collection, and special interactions using pattern matching for command parsing while maintaining immutable state where possible. The design emphasizes modularity, type safety, and clear separation of concerns, with robust error handling for invalid actions and impossible game states.


The game uses enums to represent Directions, Locations, and Items, providing type safety and clear organization. The GameState struct maintains the game's state including current location, inventory, and completion flags. The main game logic is implemented in the GyeongbokgungGame struct which conforms to the AdventureGame protocol, providing a clear interface for game operations. The protocol-based design allows for easy extension and modification of game behavior. The Sacred protocol defines behavior for places that can be blessed with items, and the SacredPlace struct conforms to this protocol.

**How do you use optionals in your program?**

Optionals are used in the SacredPlace struct to handle the requiredItem, which may be nil if no item is needed to bless the place. The game also uses optional binding in command parsing to safely extract directions and item names from user input.

**What extra credit features did you implement, if any?**

* None

## Endings

### Ending 1 (Victory)
Commands to reach this ending:
```
north
take binyeo
east
take scroll
use scroll
west
use binyeo
north
east
take incense
north
use incense
```

### Ending 2 (Banishment)
Commands to reach this ending:
```
north
take binyeo
east
west
use binyeo
north
east
north
```