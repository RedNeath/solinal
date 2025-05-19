# SoliNal Project

The SoliNal Project is about a solitaire game, written in Lua, and playable in the terminal.

Table of contents:
- [**Installation**](#installation)
   - [Installation details](#installation-details)
- [**Running the programme**](#running-the-programme)
- [**User interactions (commands)**](#user-interactions-commands)
- [**Known issues**](#known-issues)
- [**Core concepts and vocabulary**](#core-concepts-and-vocabulary)
- [**Game phases**](#game-phases)

## Installation
If you're on Linux or using WSL, that's only a 2 step process:
1. Ensure gcc (GNU C Compiler) and unzip utilities are installed;
2. run the `install.sh` script (without sudo mode!).

And you should be good to go!

If, however, you happen to want to run this app with another platform... expect to be thrown into the wilderness. You will have to recreate the install script, basing yourself on the Linux one available, as well as ensuring the required tools are installed on your machine.  
At worst, you could also simply do everything manually. That's up to you.

> **NOTE:**  
> If something goes wrong during the installation process, instead of cleaning up everything yourself before to run the `install.sh` script again, know that the `reinstall.sh` script is there to do it for ya <3

### Installation details
The `install.sh` scripts downloads the latest version of Lua to this date, straight from the official ftp server. It then unzips it in the `lua-<version>` directory, before compiling it.

Once done, it cleans up the installation a bit, by rearranging files and folders. Then it downloads Luarocks (Lua's most recognised package manager) straight off of their Github repository's releases. The downloaded archive is then unzipped into the `luarocks-<version>`.

The utility is then configured and installed locally for the project, and two modules are installed via Luarocks:
- **lunajson**;
- and **split**.

## Running the programme
Just run the `play.sh` script, or an equivalent.

## User interactions (commands)
Here's the list of the commands that the player should be able to execute:
- `moveto`, to move one of the card on the game plate (identified via its ID) to another pile (identified via its ID as well, or via the ID of the card on top of it);
- `supply`, to move a card from the stock pile to the supply pile, or to refill the stock pile when empty;
- `newgame`, to start a new game;
- `exit`, to leave the game (maybe we'll implement some saving system in the future);
- `undo`, to cancel the last action performed.

> **NOTE:**  
> `moveto` and `supply` are the two only *real* commands. The other ones affect the programme instead of the game. That is partly why they cannot be undone.

Also, pressing return with an empty input will try to execute the same command as the last one performed. This is espacially useful when supplying over and over.

> **NOTE:**  
> This will only work for *real* commands.

## Known issues
- Using the `undo` command after calling `moveto` makes the game crash.
- Using sound effects blocks the main thread, and stops execution while the sound is playing (this is why sounds are disabled).

## Core concepts and vocabulary
Below are described the core concepts of this project:
1. **TURN**: Each turn is manually triggered by the player when entering a valid turn input.
2. **DECK**: The deck represents the entirety of the **GAME**'s cards. It contains four **FAMILIES**, which are divided in two **COULOURS**. It is supposed to be shuffled before each **GAME**.
3. **FAMILY**: Club, Spade, Heart & Diamond; the four infamous families of every classical card game.
4. **COLOUR**: There are two **COLOURS** in the **GAME**: red and black. This concept is very important for the **GAME**.
5. **GAME**: The game is the frame encompassing all the concepts presented there. It is created when one starts playing, and it ends when one either wins or loses.
6. **PILE**: There are precisely four sorts of piles, each present a fixed amount of times on the **GAMES**'s **PLATE**:
   1. The first is the **BOARD** pile, which is present a total of seven times. It can contain flipped **CARDS** as well as regular (visible) **CARDS**, but only in a very specific order. Flipped **CARDS** cannot appear above regular **CARDS** within the same **BOARD** pile. Also, a **BOARD** pile's top **CARD** cannot be a flipped one, which means in cas a player action causes this sitation to happen, the **CARD** at the top of the pile must be flipped over immediately. Regular **CARDS** in a **BOARD** pile must be arranged as a sequence of opposite **COLOURS**, and in a decreasing value order.
   2. The second sort is the **PIT** pile. It is present four times across the **PIT**. One **PIT** pile may only contain **CARDS** from a single **FAMILY**, arrangaed in an increasing value order, and starting by the ace of the **FAMILY**. No user action that defies this rule will be tolerated.
   3. The third sort is the supply pile. It contains only regular **CARDS**, without any specific order. The player can remove **CARDS** from it by moving the **CARD** at the top to another pile of the two preceding sorts. To add more cards to the supply pile, the player must flip a **CARD** from the fourth sort of piles, and transfer it to the supply pile.
   4. Finally, the last sort of piles is the stock pile. As is the supply pile, the stock pile is only present once in the **GAME**'s **PLATE**. All of its card are flipped, and this pile can only transfer **CARDS** to the supply pile, as described above. Nevertheless, in case the stock pile is empty, the player can decide to fill it back with all the cards from the supply pile.
7. **BOARD**: The board is the inferior part of the **GAME**'s **PLATE**. It is composed of seven board **PILES**. At the start of the **GAME**, each **PILE** of the board is filled with zero to six flipped **CARDS**, and one regular **CARD** at the top.
8. **PIT**: The pit is located on the right of the superior part of the **GAME**'s **PLATE**. It is composed of four pit **PILES**. When the **GAME** start, the pit **PILES** are left empty. Once the four of them are all filled up, the **GAME** can be considered won.
9. **PLATE** The plate represents the entire **GAME** plate. On the left of the superior part are the stock **PILE** and the supply **PILE**. To the right of it is the **PIT**, and in the inferior part, we can find the **BOARD**.
10. **CARD**: A card is an entity that belongs to a **FAMILY** (and as of transitivity, to a **COLOUR** as well), and has a precise value ranging from 1 to 13 (= king). Each card in the **DECK** holds a unique couple of **FAMILY** and value.

## Game phases
The game will be implemented in three phases:
- initialisation, where the deck will be shuffled, then the seven board piles will be given cards from the mixed deck (one card per pile, then back to the first pile; not pile per pile), and the stock pile will be given the rest of the deck*;
- play, where the player will be allowed to interact with the game;
- finalisation, where the game is pretty much idle.

*For simplification reasons, all cards will be flipped by default.
