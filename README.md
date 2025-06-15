# 3CG - Final

Final by: 
Isaac Kim

For CMPM 121

Greekstone is a casual collectible card game (CCCG) inspired by titles like Hearthstone, Smash Up, and Nova Island. Built with Love2D and Lua, it features Greek mythology-themed cards, turn-based location battles, and a score-based win condition.

## Programming Patterns Used

### 1. **Modularization**
- Split the project into reusable modules
- To make the code more maintainable.

### 2. **Factory Pattern**
- Used in Card:new(...) and Deck:new(...) to construct card and deck objects.
- Simplifies card instantiation across different decks.

### 3. **State**
- The game uses a gamePhase state (like "play", "resolving", "gameover") to manage turn flow and phase transitions.
- Prevents interactions from running out of order or across invalid states.


## Feedback
### 1. Marcus Ochoa
The game looks like it's mostly in main. Some cleaning up could be done to use programming patterns. Game looks and works fine though.


## Postmortem

### What Went Well
- The card system and deck logic reused ideas from a prior solitaire project, speeding up core logic.
- However, there were some stuff I couldn't really apply the same as the solitaire project, and I ended up re-making the features that didn't port over so well.
- Keeping visuals simple (text-based, no drag animations yet) made testing and logic debugging easier.

### What Could Be Improved
- UI polish
- Card art

## Assets Used

- **Font**: Default LOVE2D font
- **Graphics**: None (text-based prototype)
- **Sound/Music**: None yet — to be added in future
- **Custom Work**: All game logic and card data authored by the developer
