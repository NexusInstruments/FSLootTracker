require "Window"

local FSLootTracker = Apollo.GetAddon("FSLootTracker")
local Info = Apollo.GetAddonInfo("FSLootTracker")

FSLootTracker.tDataTypes =
{
  clear = 0,
  item = 1,
  money = 2
}

FSLootTracker.tLootSources =
{
  ["Dropped"] = 0,
  ["Rolled"] = 1,
  ["Master"] = 2,
  ["Entered"] = -1
}

FSLootTracker.tLootSourcesNames =
{
  [0] = "Dropped",
  [1] = "Rolled",
  [2] = "Master",
  [-1] = "Entered"
}

FSLootTracker.tItemQualityNames = {
  ["Inferior"] = Item.CodeEnumItemQuality.Inferior,
  ["Average"] = Item.CodeEnumItemQuality.Average,
  ["Good"] = Item.CodeEnumItemQuality.Good,
  ["Excellent"] = Item.CodeEnumItemQuality.Excellent,
  ["Superb"] = Item.CodeEnumItemQuality.Superb,
  ["Legendary"] = Item.CodeEnumItemQuality.Legendary,
  ["Artifact"] = Item.CodeEnumItemQuality.Artifact,
}

FSLootTracker.tItemQuality =
{
  [Item.CodeEnumItemQuality.Inferior] =
    {
    Name			= "Inferior",
    Color			= "ItemQuality_Inferior",
    BarSprite	   	= "CRB_Tooltips:sprTooltip_RarityBar_Silver",
    HeaderSprite	= "CRB_Tooltips:sprTooltip_Header_Silver",
    SquareSprite	= "BK3:UI_BK3_ItemQualityGrey",
    CompactIcon	 	= "CRB_TooltipSprites:sprTT_HeaderInsetGrey",
    NotifyBorder	= "ItemQualityBrackets:sprItemQualityBracket_Silver",
  },
  [Item.CodeEnumItemQuality.Average] =
  {
    Name			= "Average",
    Color		   	= "ItemQuality_Average",
    BarSprite	   	= "CRB_Tooltips:sprTooltip_RarityBar_White",
    HeaderSprite	= "CRB_Tooltips:sprTooltip_Header_White",
    SquareSprite	= "BK3:UI_BK3_ItemQualityWhite",
    CompactIcon	 	= "CRB_TooltipSprites:sprTT_HeaderInsetWhite",
    NotifyBorder	= "ItemQualityBrackets:sprItemQualityBracket_White",
   },
  [Item.CodeEnumItemQuality.Good]	=
  {
    Name			= "Good",
    Color		   	= "ItemQuality_Good",
    BarSprite	   	= "CRB_Tooltips:sprTooltip_RarityBar_Green",
    HeaderSprite	= "CRB_Tooltips:sprTooltip_Header_Green",
    SquareSprite	= "BK3:UI_BK3_ItemQualityGreen",
    CompactIcon	 	= "CRB_TooltipSprites:sprTT_HeaderInsetGreen",
    NotifyBorder	= "ItemQualityBrackets:sprItemQualityBracket_Green",
    },
  [Item.CodeEnumItemQuality.Excellent] =
  {
    Name			= "Excellent",
    Color		   	= "ItemQuality_Excellent",
    BarSprite	   	= "CRB_Tooltips:sprTooltip_RarityBar_Blue",
    HeaderSprite	= "CRB_Tooltips:sprTooltip_Header_Blue",
    SquareSprite	= "BK3:UI_BK3_ItemQualityBlue",
    CompactIcon	 	= "CRB_TooltipSprites:sprTT_HeaderInsetBlue",
    NotifyBorder	= "ItemQualityBrackets:sprItemQualityBracket_Blue",
  },
  [Item.CodeEnumItemQuality.Superb] =
    {
    Name			= "Superb",
    Color		   	= "ItemQuality_Superb",
    BarSprite	   	= "CRB_Tooltips:sprTooltip_RarityBar_Purple",
    HeaderSprite	= "CRB_Tooltips:sprTooltip_Header_Purple",
    SquareSprite	= "BK3:UI_BK3_ItemQualityPurple",
    CompactIcon	 	= "CRB_TooltipSprites:sprTT_HeaderInsetPurple",
    NotifyBorder	= "ItemQualityBrackets:sprItemQualityBracket_Purple",
   },
  [Item.CodeEnumItemQuality.Legendary] =
    {
    Name			= "Legendary",
    Color		   	= "ItemQuality_Legendary",
    BarSprite	   	= "CRB_Tooltips:sprTooltip_RarityBar_Orange",
    HeaderSprite	= "CRB_Tooltips:sprTooltip_Header_Orange",
    SquareSprite	= "BK3:UI_BK3_ItemQualityOrange",
    CompactIcon	 	= "CRB_TooltipSprites:sprTT_HeaderInsetOrange",
    NotifyBorder	= "ItemQualityBrackets:sprItemQualityBracket_Orange",
    },
  [Item.CodeEnumItemQuality.Artifact] =
    {
    Name			= "Artifact",
    Color		   	= "ItemQuality_Artifact",
    BarSprite	   	= "CRB_Tooltips:sprTooltip_RarityBar_Pink",
    HeaderSprite	= "CRB_Tooltips:sprTooltip_Header_Pink",
    SquareSprite	= "BK3:UI_BK3_ItemQualityMagenta",
    CompactIcon	 	= "CRB_TooltipSprites:sprTT_HeaderInsetPink",
    NotifyBorder	= "ItemQualityBrackets:sprItemQualityBracket_Pink",
  },
}

FSLootTracker.tTimeStampFormats = {
  ["12h"] = "{YYYY}-{MM}-{DD} {hh}:{mm}:{SS} {TT}",
  ["24h"] = "{YYYY}-{MM}-{DD} {HH}:{mm}:{SS}",
}

FSLootTracker.strDefaultGuildInfoText =
  "=== FSLootTracker ===\n\n" ..
  "_.,-*~'`^`'~*-,._\n\n" ..
  "Developed By:\n" ..
  "Chrono Syz--Entity-US\n" ..
  "Copyright (c) 2014,2015\n\n" ..
  "_.,-*~'`^`'~*-,._\n\n" ..
  "<FOR SCIENCE>\n" ..
  "Dominion / PvE\n" ..
  "Entity-US\n\n" ..
  "http://forscienceguild.org\n\n" ..
  "_.,-*~'`^`'~*-,._\n"

FSLootTracker.tabColors = {
  normal = "ff181818",
  selected = "ff3e3e3e",
  hover = "ff4f4f4f"
}

FSLootTracker.tExportFormats =
{
  json = 1,
  bbcode = 2,
  html = 3,
  eqdkpxml = 4
}

FSLootTracker.tExportFormatNames =
{
  [1] = "JSON",
  [2] = "BBCode",
  [3] = "HTML",
  [4] = "EQDKP-XML 2.1"
}

FSLootTracker.tGraphWindowLengths =
{
  [1] = {
    interval = 30,
    text = "30m"
  },
  [2] = {
    interval = 60,
    text = "1hr"
  },
  [3] = {
    interval = 120,
    text = "2hr"
  },
  [4] = {
    interval = 240,
    text = "4hr"
  },
  [5] = {
    interval = -1,
    text = "∞"
  }
}

FSLootTracker.tPollingIntervals =
{
  [1] = {
    interval = 1,
    text = "1s"
  },
  [2] = {
    interval = 5,
    text = "5s"
  },
  [3] = {
    interval = 10,
    text = "10s"
  },
  [4] = {
    interval = 30,
    text = "30s"
  },
  [5] = {
    interval = 60,
    text = "1m"
  },
  [6] = {
    interval = 120,
    text = "2m"
  },
  [7] = {
    interval = 300,
    text = "5m"
  }
}
