-- OmnipotentEntity compiled in support for doing config="{...JSON...}" so this approach is how we'll proceed
function init(virtual)
if virtual then return nil end
entity.setInteractive(true)
--world.logInfo("spawningtable.lua:init(): ultimate box has done its init")

fullLabel = nil
fullTxt = nil

entity.setAnimationState("tabulaState","animate")
end

function onInteraction(args)
  buttons = generateButtons()
  return { "OpenCraftingInterface", {config={
  ["requiresBlueprint"] = false,
  ["paneLayout"] = {
    ["panefeature"] = {
      ["type"] = "panefeature",
      ["keyDismissable"] = true,
      ["persistent"] = true
    },
    ["background"] = {
      ["type"] = "background",
      ["fileHeader"] = "/interface/spawningtable/craftingheader.png",
      ["fileBody"] = "/interface/spawningtable/craftingbody.png",
      ["fileFooter"] = "/interface/spawningtable/craftingfooter.png"
    },
    ["close"] = {
      ["type"] = "button",
      ["base"] = "/interface/inventory/x.png",
      ["hover"] = "/interface/inventory/xhover.png",
      ["press"] = "/interface/inventory/xpress.png",
      ["position"] = {447, 261}
    },
    ["windowtitle"] = {
      ["type"] = "title",
      ["title"] = "  SPAWNING BOX",
      ["subtitle"] = "  It's like magic.",
      ["position"] = {-5, 252},
      ["icon"] = {
        ["type"] = "image",
        ["file"] = "/interface/spawningtable/craftingtable.png",
        ["position"] = {0, -20},
        ["zlevel"] = -1
      }
    },
    
    ["lblCategories"] = {
      ["type"] = "label",
      ["position"] = {400, 243},
      ["hAnchor"] = "mid",
      ["value"] = "CATEGORIES"
    },
	
    ["lblSchematics"] = {
      ["type"] = "label",
      ["position"] = {88, 243},
      ["hAnchor"] = "mid",
      ["value"] = "SCHEMATICS"
    },
    ["lblProducttitle"] = {
      ["type"] = "label",
      ["position"] = {265, 243},
      ["hAnchor"] = "mid",
      ["value"] = "PRODUCT"
    },
    ["spinCount"] = {
      ["type"] = "spinner",
      ["position"] = {202, 40},
      ["upOffset"] = 34
    },
    ["tbSpinCount"] = {
      ["type"] = "textbox",
      ["position"] = {214, 40},
      ["textAlign"] = "center",
      ["maxWidth"] = 15,
      ["regex"] = "x?\\d{0,3}",
      ["hint"] = ""
    },
    ["lblAmountInput"] = {
      ["type"] = "image",
      ["file"] = "/interface/crafting/amount.png",
      ["position"] = {208, 39},
      ["zlevel"] = -3
    },
    ["lbllvlSort"] = {
      ["type"] = "image",
      ["file"] = "/interface/crafting/organizelevelhigher.png",
      ["position"] = {123, 232},
      ["zlevel"] = -3
    },
    ["btnCraft"] = {
      ["type"] = "button",
      ["base"] = "/interface/button.png",
      ["hover"] = "/interface/buttonhover.png",
      ["position"] = {274, 38},
      ["caption"] = "Craft"
    },
    ["btnFilterHaveMaterials"] = {
      ["type"] = "button",
      ["base"] = "",
      ["baseImageChecked"] = "",
      ["checkable"] = true,
      ["checked"] = false,
      ["position"] = {26, 84}
    },
    ["lblProduct"] = {
      ["type"] = "label",
      ["position"] = {51, 83},
      ["hAnchor"] = "left",
      ["value"] = ""
    },

    ["scrollArea"] = {
      ["type"] = "scrollArea",
      ["rect"] = {5, 58, 174, 230},
      ["children"] = {
        ["itemList"] = {
          ["type"] = "list",
          ["schema"] = {
            ["selectedBG"] = "/interface/spawningtable/craftableselected.png",
            ["unselectedBG"] = "/interface/spawningtable/craftablebackground.png",
            ["spacing"] = {0, 1},
            ["memberSize"] = {156, 20},
            ["listTemplate"] = {
              ["background"] = {
                ["type"] = "image",
                ["file"] = "/interface/spawningtable/craftablebackground.png",
                ["position"] = {0, 0},
                ["zlevel"] = -1
              },
              ["itemName"] = {
                ["type"] = "label",
                ["position"] = {21, 11},
                ["hAnchor"] = "left",
                ["width"] = 116,
                ["value"] = "Replace Me"
              },
              ["itemIcon"] = {
                ["type"] = "itemslot",
                ["position"] = {1, 1},
                ["callback"] = "null"
              },
              ["level"] = {
                ["type"] = "label",
                ["position"] = {138, 9},
                ["hAnchor"] = "mid",
                ["value"] = "Lvl. 100"
              },
              ["newIcon"] = {
                ["type"] = "image",
                ["position"] = {129, 2},
                ["file"] = "/interface/crafting/new.png"
              },
              ["moneyIcon"] = {
                ["type"] = "image",
                ["position"] = {126, 1},
                ["file"] = "/interface/money.png"
              },
              ["priceLabel"] = {
                ["type"] = "label",
                ["position"] = {138, 1},
                ["hAnchor"] = "left",
                ["value"] = "0"
              },
              ["notcraftableoverlay"] = {
                ["type"] = "image",
                ["file"] = "/interface/crafting/notcraftableoverlay.png",
                ["position"] = {0, 0},
                ["zlevel"] = 1
              }
            }
          }
        }
      }
    },
    ["description"] = {
      ["type"] = "widget",
      ["position"] = {190, 50},
      ["size"] = {140, 220}
    },
    ["filter"] = {
      ["type"] = "textbox",
      ["position"] = {57, 43},
      ["hint"] = "Search",
      ["maxWidth"] = 70,
      ["escapeKey"] = "close",
      ["enterKey"] = "filter",
      ["focus"] = true
    },
    ["fullLabel"]=fullLabel,
    ["fullTxt"]=fullTxt,
    ["categories"] = {
      ["type"] = "radioGroup",
      ["toggleMode"] = true,
      ["buttons"] = buttons
    },
    ["rarities"] = {
      ["type"] = "radioGroup",
      ["toggleMode"] = true,
      ["buttons"] = {
        {
          ["position"] = {8, 232},
          ["baseImage"] = "/interface/crafting/sortcommon.png",
          ["baseImageChecked"] = "/interface/crafting/sortcommonselected.png",
          ["data"] = {
            ["rarity"] = { "common" }
          }
        },
        {
          ["position"] = {14, 232},
          ["baseImage"] = "/interface/crafting/sortuncommon.png",
          ["baseImageChecked"] = "/interface/crafting/sortuncommonselected.png",
          ["data"] = {
            ["rarity"] = { "uncommon" }
          }
        },
        {
          ["position"] = {20, 232},
          ["baseImage"] = "/interface/crafting/sortrare.png",
          ["baseImageChecked"] = "/interface/crafting/sortrareselected.png",
          ["data"] = {
            ["rarity"] = { "rare" }
          }
        },
        {
          ["position"] = {26, 232},
          ["baseImage"] = "/interface/crafting/sortlegendary.png",
          ["baseImageChecked"] = "/interface/crafting/sortlegendaryselected.png",
          ["data"] = {
            ["rarity"] = { "legendary" }
          }
        }
      }
    }
  },
  ["tooltip"] = {
    ["panefeature"] = {
      ["type"] = "panefeature"
    },
    ["itemList"] = {
      ["position"] = {2, 3},
      ["type"] = "list",
      ["schema"] = {
        ["spacing"] = {0, 0},
        ["memberSize"] = {125, 25},
        ["listTemplate"] = {
          ["itemName"] = {
            ["type"] = "label",
            ["position"] = {22, 10},
            ["hAnchor"] = "left",
            ["wrapWidth"] = 116,
            ["value"] = "Golden Moustache"
          },
          ["itemIcon"] = {
            ["type"] = "itemslot",
            ["position"] = {1, 1},
            ["callback"] = "null"
          },
          ["count"] = {
            ["type"] = "label",
            ["position"] = {118, 0},
            ["hAnchor"] = "right",
            ["value"] = "19/99"
          }
        }
      }
    }
  }
},
filter={"spawningtable"} }}
end

function generateButtons()
local buttonArrayX = 340
local buttonArrayY = 220
local buttonArrayMaxWidth = 2
local buttonArrayMaxHeight = 11
local buttonArrayHSpacing = 61
local buttonArrayVSpacing = 20

local buttons = entity.configParameter("filterButtons")

--world.logInfo("'buttons' is set to %s",buttons)

local b = {
        
      }

  local num = 1
  for _,bt in ipairs(buttons) do
    --world.logInfo("iteration %d, bt is %s",num,bt)
    --for k,v in pairs(bt) do world.logInfo("key %s is val %s",k,v) end
    if num > buttonArrayMaxWidth*buttonArrayMaxHeight then 
      fullLabel = {
        ["type"] = "image",
        ["file"] = "/interface/spawningtable/maxbuttons.png",
        ["position"] = {buttonArrayX, 23},
        ["zlevel"] = 3
        }
      fullTxt = {
      ["type"] = "label",
      ["position"] = {buttonArrayX+8, 24},
      ["hAnchor"] = "left",
      ["value"] = tostring(#buttons-buttonArrayMaxWidth*buttonArrayMaxHeight) .." mod filters not shown",
      ["zlevel"] = 4
    }
      break 
    end
    local x = buttonArrayX + buttonArrayHSpacing*( (num-1) % buttonArrayMaxWidth )
    local y = buttonArrayY - buttonArrayVSpacing*math.floor((num-1)/buttonArrayMaxWidth)
    
    if not bt["baseImage"] then bt["baseImage"] = "/interface/spawningtable/iconmissing.png" end
    if not bt["baseImageChecked"] then bt["baseImageChecked"] = "/interface/spawningtable/iconmissingchecked.png" end
    
    local bnew = nil
    if bt["filter"] then
      bnew = {
        position = {x,y},
        baseImage = bt["baseImage"],
        baseImageChecked = bt["baseImageChecked"],
        data = {
          filter = { bt["filter"] }
        }
      }
      num = num + 1
    --else
      --world.logInfo("Warning: Tabula Rasa is skipping a button with no filter set, 'bt' is %s",bt)
    end
    table.insert(b,bnew)
end
      
return b
end
