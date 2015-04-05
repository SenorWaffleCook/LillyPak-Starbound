# Current known codes: (updated 1/12/2015)

- *OLD* `/ruinthefun` : toggles admin commands
- `/admin` : used to activate admin commands (now is a toggle command)
- `/godmode` : new admin mode?
   - you can type "up arrow key" to repeat the last command used. (now an active use key)
- `/help <commandName>` : Available commands are: %s. Use /help <commandName> to get detailed documentation.,
- `/reload` : Reloads your local, client side assets. Will cause lag as they are reparsed.,
- `/serverreload` : Reloads the remote, server side assets. Will cause lag as they are reparsed.,
- `/timewarp [timeInSeconds]` : Warp time ahead by timeInSeconds.,
- `/spawnitem [itemName] [count] [variantParameters]` : Spawn the specified item at the mouse cursor. If the item does not exist it will spawn a perfectly generic item. Count expects an integral number. Variant parameters are parameters passed to the item's constructor. They are specified as JSON. Best practice is to surround JSON in single quotes.

> ### You can spawn different colors of armor using the JSON code -   
> - Example: using direct code   
>   - `/spawnitem bonusarmorchest 1 '{"directives":"?replace;6f2919=151515;a85636=383838;e0975c=555555;ffca8a=838383"}'`   
> That will spawn a BLACK Makeshift Chest Armor.   
> - Example:  using colorindex code   
>   - `/spawnitem bonusarmorchest 1 '{"colorIndex":8}'`   
>       Spawns a BLUE Makeshift Chest Armor   
> 
> You can Specify more than one JSON code to change by listing them as you would in a regular JSON file. 
>   
> - Example: (using chests)
>    - `/spawnitem wreckcrate1 1 '{"slotCount":64,"color":"red"}'`
>      - Without the game being modded most all of the storage units cannot be colored even though they have different color frames.

- `money [amount]` : Spawns money at a specified amount.

> ### Interesting items to spawn   
> - **Infinity Express** - `/spawnitem infinityexpress`   
> - **Penguin Bay** - `/spawnitem penguinbay`   
> - **Terramart** - `/spawnitem terramart`   
> - **Treasured Trophies** - `/spawnitem treasuredtrophies`   
> - `/spawnitem apexsteelstaff1`   
> - `/spawnitem novakidlightstaff1`   
> - `/spawnitem liquidgun`   

- `/spawnmonster [monsterType] [level] [varianyParametes]` : Spawn the specified monster type at the mouse cursor. If level is not specified it takes level `0`. Variant parameters are parameters passed to the monster's constructor. They are specified as JSON. Best practice is to surround JSON in single quotes.

> ### Monster Types
> #### Ground:
> - jellyboss
> - quadruped
> - robotboss
> - skeyejelly
> - shroom
> - biped
> **(large, small)**
> 
> #### Flying:
> - bonebird
> - dragonboss
> -smallflying
> 
> #### Swimming:
> - fish (untested)
>
> #### Unique:
> - allergen
> - apexbrainmutant
> - aviansentry
> - chesttrapper
> - chicken
> - cleaningbot
> - giftmonster
> - glitchknight
> - glitchspider
> - heckblob
> - missile
> - penguin
> - penguinminiufo
> - penguintank
> - penguinufo
> - pinfriend
> - po
> - pogolem
> - repairbot
> - robotchicken
> - serpentdroid
> - sewerfly
> - swarpion
> - toxicfly
> - toxicgolem

- `/spawnnc [species] [type] [level]` : Spawn an NPC of that specified species. If type is specified it spawns on the specific NPC type (for instance, `guard`). If level is not specified it takes level `0`.,
- `/spawnliquid [liquidID] [quantity]` : Spawns a liquid at mouse cursor
- `/spawngun [level] [kind]` : Spawn a randomized gun with the given level. If kind is specified then the gun is limited to that kind (for instance, `commonshotgun`). If you want to spawn a non-randomly generated gun use `/spawnitem` instead.,
- `/spawnsword [level] [kind]` : Spawn a randomized sword with the given level. If kind is specified then the sword is limited to that kind (for instance, `commonshortsword`). If you want to spawn a non-randomly generated sword use `/spawnitem` instead.,
- `/spawnshield [level] [kind]` : Spawn a randomized shield with the given level. If kind is specified then the shield is limited to that kind (for instance, `riotshield`). If you want to spawn a non-randomly generated shield use `/spawnitem` instead.,
- `/pvp` : Toggle your Player VS Player mode if possible.,
- `/serverwhoami` : Display your server username and admin status.,
- `/whoami` : Display your local username and admin status.,
- `/message [message]` : Same as sending a message by just pressing enter and typing. Useful for avoiding having your messaged parsed by the command parser.,
- `/showhunger` : Displays your hunger bar for several seconds.,
- `/played` : Displays how long you've played this character.,
- `/itemid [bagSpecifier] [slotSpecifier]` :  Dumps item information to the command line. bagSpecifier is a number between 1 and 6 or one of (case insensitive) `\bag\, \tilebag\, \bar\, \equipment\, \wieldable\, \swap\`. slotSpecifier is dependent on the bag type. If type is `bag, tilebag, 1 or 2` then slotSpecifier is a number between `0 and 39` inclusive. If type is `bar or 3` then slotSpecifier is a number between `0 and 9` inclusive. If type is `equipment or 4` then slotSpecifier is a number between `0 and 12` inclusive or one of (**case insensitive**) `\head\, \chest\, \legs\, \back\, \headSoc\, \chestSoc\, \legsSoc\, \backSoc\, \tech1\, \tech2\, \tech3\, \tech4\, \trash\`. If type is `wieldable` then slotSpecifier is either `0 or 1` or (**case insensitive**) `\lefthand\ or \righthand\`. If type is swap then only `0` is valid.,
- `/gravity` : Display the gravity at the player's position.,
- `/debug` : Enable debugging mode.,
- `/togglelogmap` : Toggle the display of debugging text information to the screen if debug mode is enabled.,
- `/boxes` : Toggle the display of debugging polygons if debug mode is enabled. Generally collision and sensor information.,
- `/clearboxes` : Toggle whether or not to clear boxes displayed with `/boxes` every frame. Useful for determining routes that enemies take, can get messy looking though.,
- `/togglelayer` : Toggle the visibility of the specified layer. A layer is a number between `1 and 21`. They are in order: Sky, Parallax, UndergroundParallax, Background, Platforms, Plant, PlantDrop, Object, CursorHintedObject, ParticlesBottom, Effect, Projectile, NPC, Player, ItemDrop, Water, ParticlesMiddle, Foreground, ParticlesTop, Nametag, InfoBars.,
- `/fullbright` : Disable the lighting engine and show everything.,
- `/setgravity [level]` : Sets your local gravity to the level specified. Standard gravity is `80`. Negative values will make you fall up but you can't jump from your head. This change is local only, and looks pretty henious on a server, because it screws very heavily with delta prediction.,
- `/resetgravity` : Undoes `/setgravity`. Begin using server gravity again.,
- `/kick [playerSpecifier] [reason]` : Kick the specified player and send the reason to the player. If no reason is specified then the player's server nickname is used as the reason (IRC Style).,
- `/ban [playerSpecifier] [reason] <kind> <timeInSeconds>` : Kick and ban the specified player and send the reason to the player. If no reason is specified then the player's server nickname is used as the reason (IRC Style). Kind is specified as `\uuid\ or \ip\ or \both\`. Other values are invalid. If kind is not specified or incorrectly specified then `\both\` is used. `timeInSeconds` defaults to forever. Bans that have a specified duration are not persistent. If you shut down the server or reload configuration, all of your temporarily banned users will be unbanned immediately.,
- `/list` : List all clients logged into the server. Format is `$clientId : serverNickname : $$playerUuid`. If the `serverNickname` contains unprintable characters the unicode escape sequence for those characters will be displayed instead.,
- `/toplayership [playerSpecifier]` : Warp self to the specified player's ship.
- `/fixedcamera` : locks the camera on screen and not on the player.  Useful for shooting video.
- `/aiaction` : Spawn techs for use on the ship ai, listed below...

> ### List of ai actions
> - `/aiaction { "action" : "enableTech", "techName" : "doublejumpTech" }`
> - `/aiaction { "action" : "enableTech", "techName" : "dashTech" }`
> - `/aiaction { "action" : "enableTech", "techName" : "bounceTech" }`
> - `/aiaction { "action" : "enableTech", "techName" : "groundsmash" }`
> - `/aiaction { "action" : "enableTech", "techName" : "rocketjump" }`
> - `/aiaction { "action" : "enableTech", "techName" : "boatTech" }`
> - `/aiaction { "action" : "enableTech", "techName" : "morphballTech" }`
> - `/aiaction { "action" : "enableTech", "techName" : "gravitybubbletech" }`
> - `/aiaction { "action" : "enableTech", "techName" : "lightrig" }`
> - `/aiaction { "action" : "enableTech", "techName" : "targetblinktech" }`
> - `/aiaction { "action" : "enableTech", "techName" : "ftlboostTech" }`
> - `/aiaction { "action" : "enableTech", "techName" : "rocketbootsTech" }`
> - `/aiaction { "action" : "enableTech", "techName" : "energyregen" }`
> - `/aiaction { "action" : "enableTech", "techName" : "bubbleboost" }`
> - `/aiaction { "action" : "enableTech", "techName" : "shieldTech" }`
> - `/aiaction { "action" : "enableTech", "techName" : "humanMechTech" }`
> - `/aiaction { "action" : "enableTech", "techName" : "regeneration" }`
> - `/aiaction { "action" : "enableTech", "techName" : "particlethrust" }`
> - `/aiaction { "action" : "enableTech", "techName" : "humancar" }`
> - `/aiaction { "action" : "enableTech", "techName" : "humanjeep" }`
> - `/aiaction { "action" : "enableTech", "techName" : "breathprotectionTech" }`
> - `/aiaction { "action" : "enableTech", "techName" : "coldprotectionTech" }`
> - `/aiaction { "action" : "enableTech", "techName" : "heatprotectionTech" }`
> - `/aiaction { "action" : "enableTech", "techName" : "radiationprotectionTech" }`

---

> ### Useful Server codes:
> - How to protect the spawn area using the new admin commands...
>      - `/debug` : (shows the dungeonId where your cursor is)
>      - `/settileprotection [dungeonId] [true|false]` : (turn tile protection on or off for the specified `dungeonId`)
>      - `/setspawnpoint` : (set the spawn area for the current world to your character's current position)

---

# QUEST GUIDE (as of 12/19/2014)
***QUEST/UPGRADE GUIDE***

(Quest groups and upgrades must be done in this order, completing all in a section unlocks the section below it.  Each section lists the items needed to complete the quests in that section.)   
(Note that upgrades done through S.A.I.L. (MM, ship) do not require anything in admin mode (does not count ship upgrade licenses, you still need the diamonds for those quests.)   


### *The Beginning - Upgrade to Ship Level 1*
(reboot AI)   
(get matter manipulator level 0 [tile damage 1.0, block radius 2] - no requirements)   
(can now use teleporter)   
(can now unlock double jump, bounce, dash techs - each unlock requires blanktechcard)   


### *Fix Engines - Upgrade to Ship Level 2*
corefragmentore (20)   
(can now travel within the solar system)   
(can now upgrade MM to level 1 - liquid collect [tile damage 1.0, block radius 2, collect liquids] - requires   silverbar (10))


### *Outpost Initial Quests*
ironbar (20)
liquidcoffee
glasscoffeemug
steelspoon


### *Tier 1 Quests*
cake
coolchest
comedyscript (find it in the restroom trash can)
diamond
climbingrope (10)
(last is optional, find at bottom of the outpost asteroid, use climbing ropes or grappling hook to get there)


### *Erchius Mining Facility Mission Unlock Quest*
(Steel Armor Set - aviantier2pants, aviantier2head, aviantier2chest or your racial equivalent) (only need 1 armor piece)


### *Fix FTL - Upgrade to Ship Level 3* (using reward from mission above)
supermatter (20)
(can now upgrade MM to level 2 - damage increase [tile damage 2.0, block radius 2, collect liquids] - requires goldbar (10))


(You'll need to fix your FTL drive (do the Erchius Mining Facility mission) before the next section unlocks.)
(The Penguin Bay "vendor" to the far right offers the ship upgrade quests.)


### *Ship Upgrade 1 - Upgrade to Ship Level 4*
diamond (2) (for license)
uraniumrod (10)
titaniumbar (10)
(can now unlock ground smash, rocket jump, boat techs - each unlock requires blanktechcard)
(can now upgrade MM to level 3 - radius increase [tile damage 2.0, block radius 3, collect liquids] - requires platinumbar (10))   


### *Tier 2 Quests*
copperbar (10)   
paper (5)   
mysteriousashes   
fullwood1   
gunpowder (5)   
coconut (3)   


### *Ship Upgrade 2 - Upgrade to Ship Level 5*
diamond (4) (for license)   
uraniumrod (20)   
durasteelbar (10)   
(can now unlock morph ball, gravity bubble, lightrig(?) techs - each unlock requires blanktechcard)   
(can now get paint tool - nothing required)   


### *Tier 3 Quests*
moonemblem   
cheese   
liquidpoison   
medievalcodex   
string   


### *Ship Upgrade 3 - Upgrade to Ship Level 6*
diamond (8) (for license)   
uraniumrod (40)   
refinedrubium (3)   
refinedviolium (3)   
refindaegisalt (3)   
(can now unlock target blink, ftlboost(?), rocket boots techs - each unlock requires blanktechcard)   
(can now get wire tool - nothing required)   


### *Tier 4 Quests*
winningticket   
treasuremap   
leather   
goldenducky   
floranbonedisplay2   
prisonstonesign   


### *Ship Upgrade 4 - Upgrade to Ship Level 7*
diamond (16) (for license)   
plutoniumrod (10)   
imperviumcompound (3)   
ceruliumcompound (3)   
feroziumcompound (3)   
(can now unlock energy regen, bubble boost, shield techs - each unlock requires blanktechcard)   
(can now upgrade MM to level 4 - damage increase [tile damage 3.0, block radius 3, collect liquids] - requires   diamond (10))   


### *Ship Upgrade 5 - Upgrade to Ship Level 8*
diamond (32) (for license)
solariumstar (20)
(can now unlock human mech, regeneration, particle thrust techs - each unlock requires blanktechcard)


### *End Game Quests*
bluestim (5)   
paperwingsback   
medievalglobe   
orange   
bone   
kennel   
cookedfish   



### *Arcade Machine*
Beat the game to get the Winning Ticket (required by a quest above) - Currently broken, you'll need to spawn the winningticket item.   
The arcade machine now uses a maze game.  Find your way out to win.

**You'll need to go back to your ship after obtaining the ship licence(s) and tell S.A.I.L. to upgrade before the next set of quests unlock.**

## Upgrading the ship

### To Fix the ship:

`/spawnitem shiprepairkit 1`   
`/spawnitem FTLrepairkit 1`   
`/spawnitem ShipT3`   

### To Upgrade the ship:

`/spawnitem shipTx`   
Where x = levels 2-8

---

# Websites
[Starbound Items at herokuapp.com](http://starbounditems.herokuapp.com/)   
[Kawa's Starbound JSON Lab](http://helmet.kafuka.org/sbmods/json/)   
[Star Reader](http://c4isbad.com/starreader/)   

---

# Other gameplay mechanics to watch out for...

### Mining -
Pickaxes are no long repairable, but mine at a faster rate.

### NPCs -

#### Monsters -
some designs are not available or spawning while they are being worked on.

###### Other things?

# BUGS!!!! (updated 12/20/2014)

### To Be Listed!!!

---

Thanks all!