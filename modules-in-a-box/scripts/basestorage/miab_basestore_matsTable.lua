-- to look up a material, use matsTable["blockName"]
-- some blocks have no corresponding material item, these will return nil
-- some material items don't correspond with a block, these are omitted since we should never have to deal with them
matsTable = {}
	matsTable["aztec"] = "aztecmaterial"
	matsTable["brick"] = "brickmaterial"
	matsTable["cobblestone"] = "cobblestonematerial"
	matsTable["composite01"] = "composite01material"
	matsTable["concrete"] = "concretematerial"
	matsTable["darksmoothstone"] = "darksmoothstonematerial"
	matsTable["darkwood"] = "darkwoodmaterial"
	matsTable["dirt"] = "dirtmaterial"
	matsTable["girdir"] = "girdirmaterial"
	matsTable["glass"] = "glassmaterial"
	matsTable["gravel"] = "gravelmaterial"
	matsTable["hellstone"] = "hellstonematerial"
	matsTable["metallic"] = "metallicmaterial"
	matsTable["plate"] = "platematerial"
	matsTable["purplecrystal"] = "purplecrystalmaterial"
	matsTable["rock01"] = nil
	matsTable["rock02"] = nil
	matsTable["rock03"] = nil
	matsTable["rock04"] = nil
	matsTable["rockbrick"] = "rockbrickmaterial"
	matsTable["sand"] = "sand"
	matsTable["sand2"] = "sand2"
	matsTable["sandstone01"] = "sandstonematerial"
	matsTable["crosshatch"] = "crosshatch"
	matsTable["temple1"] = "temple1"
	matsTable["temple2"] = "temple2"
	matsTable["temple3"] = "temple3"
	matsTable["temple4"] = "temple4"
	matsTable["snow"] = "snow"
	matsTable["slush"] = "slush"
	matsTable["ice"] = "ice"
	matsTable["goldblock"] = "goldblock"
	matsTable["silverblock"] = "silverblock"
	matsTable["platinumblock"] = "platinumblock"
	matsTable["obsidian"] = "obsidian"
	matsTable["ash"] = "ash"
	matsTable["blaststone"] = "blaststone"
	matsTable["platform"] = "platform"
	matsTable["brains"] = "brains"
	matsTable["hive"] = "hive"
	matsTable["slime"] = "slime"
	matsTable["smoothmetal"] = "smoothmetal"
	matsTable["drysand"] = "drysand"
	matsTable["drydirt"] = "drydirt"
	matsTable["direstone"] = "direstone"
	matsTable["modernplatform"] = "modernplatform"
	matsTable["tar"] = "tar"
	matsTable["wetdirt"] = "wetdirt"
	matsTable["rustymetal"] = "rustymetal"
	matsTable["wreckplatform"] = "wreckplatform"
	matsTable["clay"] = "clay"
	matsTable["mud"] = "mud"
	matsTable["aztectech"] = "aztectech"
	matsTable["bars"] = "bars"
	matsTable["fadedblocks"] = "fadedblocks"
	matsTable["fullwood1"] = "fullwood1"
	matsTable["homewalls1"] = "homewalls1"
	matsTable["techhull1"] = "techhull1"
	matsTable["tombbrick"] = "tombbrick"
	matsTable["tombbrick2"] = "tombbrick2"
	matsTable["tombbrick3"] = "tombbrick3"
	matsTable["tombbrick4"] = "tombbrick4"
	matsTable["tombbrick5"] = "tombbrick5"
	matsTable["woodbridge"] = "woodbridge"
	matsTable["woodenwindow1"] = "woodenwindow1"
	matsTable["woodenwindow2"] = "woodenwindow2"
	matsTable["steelplatform"] = "steelplatform"
	matsTable["tribalplatform"] = "tribalplatform"
	matsTable["woodenplatform"] = "woodenplatform"
	matsTable["rock12"] = nil
	matsTable["rock15"] = nil
	matsTable["rock17"] = nil
	matsTable["rock19"] = nil
	matsTable["rock20"] = nil
	matsTable["rock14"] = nil
	matsTable["moondust"] = "moondust"
	matsTable["moonrock"] = "moonrock"
	matsTable["moonstone"] = "moonstone"
	matsTable["redtoyblock"] = "redtoyblock"
	matsTable["magmarock"] = "magmarock"
	matsTable["stonetiles"] = "stonetiles"
	matsTable["baseboard"] = "baseboard"
	matsTable["wallpaper"] = "wallpaper"
	matsTable["chain"] = "chain"
	matsTable["junktech"] = "junktech"
	matsTable["lightmetal"] = "lightmetal"
	matsTable["mediummetal"] = "mediummetal"
	matsTable["cheapwallpaper"] = "cheapwallpaper"
	matsTable["woodpanelling"] = "woodpanelling"
	matsTable["wicker"] = "wicker"
	matsTable["thatch"] = "thatch"
	matsTable["fullwood2"] = "fullwood2"
	matsTable["platform2"] = "platform2"
	matsTable["blackglass"] = "blackglass"
	matsTable["shojiscreenpanel"] = "shojiscreenpanel"
	matsTable["bamboo"] = "bamboo"
	matsTable["bambooplatform"] = "bambooplatform"
	matsTable["fence"] = "fence"
	matsTable["bookpiles"] = "bookpiles"
	matsTable["rooftiles"] = "rooftiles"
	matsTable["castlewalls1"] = "castlewalls1"
	matsTable["castlewalls2"] = "castlewalls2"
	matsTable["medievalladder"] = "medievalladder"
	matsTable["stoneplatform"] = "stoneplatform"
	matsTable["plantplatform"] = "plantplatform"
	matsTable["ironblock"] = "ironblock"
	matsTable["sandstoneblock"] = "sandstoneblock"
	matsTable["bonematerial"] = "bonematerial"
	matsTable["iceblock"] = "iceblock"
	matsTable["frozenwater"] = nil
	matsTable["cobblestonebrick"] = "cobblestonebrick"
	matsTable["packeddirt"] = "packeddirt"
	matsTable["plantmatter"] = "plantmatter"
	matsTable["mossypackeddirt"] = "mossypackeddirt"
	matsTable["sewage"] = "sewage"
	matsTable["sewerpipehorizontal"] = "sewerpipehorizontal"
	matsTable["sewerpipevertical"] = "sewerpipevertical"
	matsTable["copperplatform"] = "copperplatform"
	matsTable["copperladder"] = "copperladder"
	matsTable["plantblock"] = "plantblock"
	matsTable["corruptdirt"] = "corruptdirtmaterial"
	matsTable["neonblock"] = "neonblock"
	matsTable["pressurizedbeam"] = "pressurizedbeam"
	matsTable["pressurizedgirder"] = "pressurizedgirder"
	matsTable["pressurizedsteel"] = "pressurizedsteel"
	matsTable["ornatewood"] = "ornatewood"
	matsTable["ornatewall"] = "ornatewall"
	matsTable["ornatetiles"] = "ornatetiles"
	matsTable["ornateflooring"] = "ornateflooring"
	matsTable["ornateroofing"] = "ornateroofing"
	matsTable["pressurizedplatform"] = "pressurizedplatform"
	matsTable["meteoriterock"] = "meteoriterock"
	matsTable["shroomblock"] = "shroomblock"
	matsTable["rainbowwoodblock"] = "rainbowwoodblock"
	matsTable["crystalblock"] = "crystalblock"
	matsTable["fleshblock"] = "fleshblock"
	matsTable["rustyblock"] = "rustyblock"
	matsTable["apexshipdetails"] = "apexshipdetails"
	matsTable["apexshipsupport"] = "apexshipsupport"
	matsTable["apexshipwall"] = "apexshipwall"
	matsTable["throwingblock"] = nil
	matsTable["vine"] = "vine"
	matsTable["matterblock"] = "matterblock"
	matsTable["candyblock"] = "candyblock"
	matsTable["apexshipplatformplatform"] = "apexshipplatform"
	matsTable["skyrailplatform"] = "skyrailplatform"