local t = Def.ActorFrame {
    Name = "UnderlayFile",
    BeginCommand = function(self)
        -- if theres no songs loaded send them to the bundle screen once
        if SONGMAN:GetNumSongGroups() == 0 and not SCUFF.visitedCoreBundleSelect then
            SCUFF.visitedCoreBundleSelect = true
            SCREENMAN:SetNewScreen("ScreenCoreBundleSelect")
        end
    end,
}

t[#t+1] = LoadActor(THEME:GetPathG("Title", "BG"))

local gradientwidth = 1104 / 1920 * SCREEN_WIDTH
local gradientheight = SCREEN_HEIGHT
local separatorxpos = 814 / 1920 * SCREEN_WIDTH -- basically the top right edge of the gradient
local separatorthickness = 22 / 1920 * SCREEN_WIDTH -- very slightly fudged due to measuring a diagonal line
local separatorlength = math.sqrt(SCREEN_HEIGHT * SCREEN_HEIGHT + (gradientwidth - separatorxpos) * (gradientwidth - separatorxpos)) + 10 -- hypotenuse

local logoFrameUpperGap = 39 / 1080 * SCREEN_HEIGHT -- from top edge to logo
local logoFrameLeftGap = 61 / 1920 * SCREEN_WIDTH -- from left edge to logo
local logoNameLeftGap = 14 / 1920 * SCREEN_WIDTH -- from end of logo to left of text
local logoThemeNameLeftGap = 33 / 1920 * SCREEN_WIDTH -- from end of logo to left of text
local logoThemeNameUpperGap = 67 / 1080 * SCREEN_HEIGHT -- from top of name text to top of theme text
local logosourceHeight = 133
local logosourceWidth = 102
local logoratio = math.min(1920 / SCREEN_WIDTH, 1080 / SCREEN_HEIGHT)
local logoH, logoW = getHWKeepAspectRatio(logosourceHeight, logosourceWidth, logosourceWidth / logosourceWidth)

local versionNumberLeftGap = 5 / 1920 * SCREEN_WIDTH
local versionNumberUpperGap = 980 / 1080 * SCREEN_HEIGHT
local themeVersionUpperGap = 1015 / 1080 * SCREEN_HEIGHT

local translations = {
    GameName = THEME:GetString("Common", "Etterna"):upper(),
    UpdateAvailable = THEME:GetString("ScreenTitleMenu", "UpdateAvailable"),
    By = THEME:GetString("ScreenTitleMenu", "By"),
}

local nameTextSize = 0.9
local themenameTextSize = 1.1
local versionTextSize = 0.5
local versionTextSizeSmall = 0.25
local animationSeconds = 0.5 -- the intro animation
local updateDownloadIconSize = 30 / 1080 * SCREEN_HEIGHT

-- information for the update button
local latest = tonumber((DLMAN:GetLastVersion():gsub("[.]", "", 1)))
local current = tonumber((GAMESTATE:GetEtternaVersion():gsub("[.]", "", 1)))
if latest ~= nil and current ~= nil and latest > current then
    updateRequired = true
end

-- if you go to the help screen this puts you back on the main menu
SCUFF.helpmenuBackout = "ScreenTitleMenu"

songIni = load_conf_file(THEME:GetPathO("Menu", "selectedsong"))
songIniChoice = songIni.SongSelect.CurrentChoice
songChoice = tostring(songIniChoice)
songLen, songLoop = FindSoundLength(songChoice)

-- for the secret jukebox button
local playingMusic = {}
local playingMusicCounter = 1

local buttonHoverAlpha = 0.6
local function hoverfunc(self)
    if self:IsInvisible() then return end
    if isOver(self) then
        self:diffusealpha(buttonHoverAlpha)
    else
        self:diffusealpha(1)
    end
end

local function clickDownload(self, params)
    if self:IsInvisible() then return end
    if not params or params.event ~= "DeviceButton_left mouse button" then return end
    GAMESTATE:ApplyGameCommand("urlnoexit,https://github.com/etternagame/etterna/releases;text,GitHub")
end

t[#t+1] = Def.ActorFrame {
    Name = "LeftSide",
    InitCommand = function(self)
        self:x(-SCREEN_WIDTH)
    end,
    BeginCommand = function(self)
        self:smooth(animationSeconds)
        self:x(0)
    end,

    Def.Actor {
        Name = "MenuBGM",
        InitCommand = function(self)
            self:queuecommand("On")
        end,
        OnCommand = function(self)
            SOUND:PlayMusicPart("/Themes/pitchBlende/sounds/" .. songChoice, 0, songLen, 0, 0, songLoop, false, true)
        end,
        OffCommand = function(self)
            SOUND:StopMusic()
        end,
        SongModifiedMessageCommand = function(self, params)
            SOUND:StopMusic()
            local songChoice = tostring(params.choice)
            local songLen = tonumber(params.length)
            local songLoop = (tostring(params.hasLoop) == "true") and true or false
            SOUND:PlayMusicPart("/Themes/pitchBlende/sounds/" .. songChoice, 0, songLen, 0, 0, songLoop, false, true)
        end
    },
    Def.Sprite {
        Name = "LeftBG",
        Texture = THEME:GetPathG("", "title-gradient"),
        InitCommand = function(self)
            self:halign(0):valign(0)
            self:zoomto(gradientwidth, gradientheight)
            self:diffusealpha(0.85)
            self:draworder(9998)
        end
    },
    Def.Sprite {
        Name = "LeftBG",
        Texture = THEME:GetPathG("", "bg-title-gradient"),
        InitCommand = function(self)
            self:halign(0):valign(0)
            self:zoomto(gradientwidth, gradientheight)
            self:diffusealpha(1)
            self:draworder(9997)
        end
    },
    Def.Quad {
        Name = "SeparatorShadow",
        InitCommand = function(self)
            self:halign(0):valign(0)
            self:zoomto(separatorthickness * 3, separatorlength)
            self:x(separatorxpos - separatorthickness)
            self:diffuse(color("0,0,0,1"))
            self:fadeleft(1)
            self:faderight(1)
            local ang = math.atan((gradientwidth - separatorxpos) / separatorlength)
            self:rotationz(-math.deg(ang))
            self:draworder(9999)
        end
    },
    Def.Quad {
        Name = "Separator",
        InitCommand = function(self)
            self:halign(0):valign(0)
            self:zoomto(separatorthickness, separatorlength)
            self:x(separatorxpos)
            local ang = math.atan((gradientwidth - separatorxpos) / separatorlength)
            self:rotationz(-math.deg(ang))
            self:diffuse(COLORS:getTitleColor("Separator"))
            self:diffusealpha(1)
            self:draworder(9999)
        end
    },
    LoadFont("Menu Bold") .. {
        Name = "GameName",
        InitCommand = function(self)
            self:halign(0):valign(0)
            self:xy(logoNameLeftGap + logoW - logoFrameLeftGap, logoFrameUpperGap)
            self:zoom(nameTextSize)
            self:maxwidth((separatorxpos - (logoNameLeftGap + logoW) - logoNameLeftGap) / nameTextSize)
            self:settext(translations["GameName"])
            self:diffuse(COLORS:getTitleColor("PrimaryText"))
            self:diffusealpha(1)
            self:draworder(9999)
        end
    },
    Def.BitmapText {
        Name = "ThemeName",
        Font = "_sacramento 48px",
        InitCommand = function(self)
            self:halign(0):valign(0)
            self:xy((logoThemeNameLeftGap + logoW - logoFrameLeftGap) + 24, logoThemeNameUpperGap + logoFrameUpperGap)
            self:zoom(themenameTextSize)
            self:maxwidth((separatorxpos - (logoNameLeftGap + logoW) - logoThemeNameLeftGap) / themenameTextSize)
            self:settext(getThemeName())
            self:diffusealpha(1)
            self:diffuse(color("#AAAAAA"))
            self:draworder(9999)
        end
    },
    Def.BitmapText {
        Name = "ThemeVersionAndCredits",
        Font = "Menu Normal",
        InitCommand = function(self)
            self:halign(0):valign(0)
            self:xy(versionNumberLeftGap + logoFrameLeftGap, themeVersionUpperGap)
            self:maxwidth((gradientwidth - versionNumberLeftGap - logoFrameLeftGap - separatorthickness) / versionTextSizeSmall)
            self:zoom(versionTextSizeSmall)
            self:settext("etterna v"..GAMESTATE:GetEtternaVersion().."\n("..getThemeName()..", "..getThemeVersion().."@"..getThemeDate().." " .. translations["By"] .. " "..getThemeAuthor()..")")
            self:diffuse(COLORS:getTitleColor("SecondaryText"))
            self:diffusealpha(1)
            self:draworder(9999)
        end,
        CreditsMessageCommand = function(self)
            if not(self:GetText() == "This theme was also brought to      Etterna is based on StepMania,\nyou by poco0317 and Celebelian,   which was originally\nwho worked on the base theme.    created by the people credited in STEPMANIA.TXT.\n\nGreetz to all the people who gave me feedback, you know who you are :^)") then
                self:xy(-384,themeVersionUpperGap - 48)
                self:spring(0.25)
                self:x((versionNumberLeftGap + logoFrameLeftGap) - 32)
                self:settext("This theme was also brought to      Etterna is based on StepMania,\nyou by poco0317 and Celebelian,   which was originally\nwho worked on the base theme.    created by the people credited in STEPMANIA.TXT.\n\nGreetz to all the people who gave me feedback, you know who you are :^)")
            else
                self:xy(-384,themeVersionUpperGap)
                self:spring(0.25)
                self:x(versionNumberLeftGap + logoFrameLeftGap)
                self:settext("etterna v"..GAMESTATE:GetEtternaVersion().."\n("..getThemeName()..", "..getThemeVersion().."@"..getThemeDate().." " .. translations["By"] .. " "..getThemeAuthor()..")")
            end
        end
    }
}




local scrollerX = 99 / 1920 * SCREEN_WIDTH
local scrollerY = 440 / 1920 * SCREEN_HEIGHT + 90
local selectorHeight = 70 / 1080 * SCREEN_HEIGHT
local selectorWidth = 574 / 1920 * SCREEN_WIDTH
local choiceTable = strsplit(THEME:GetMetric("ScreenTitleMenu", "ChoiceNames"), ",")

t[#t+1] = Def.ActorFrame {
    Name = "SelectionFrame",
    BeginCommand = function(self)
        -- i love hacks.
        -- this makes all positioning and everything relative to the scroller actorframe
        -- because we cant actually make the scroller we want
        -- so we do this way
        -- and this is the actorframe responsible for the highlight on the title screen choices.
        local scr = SCREENMAN:GetTopScreen():GetChild("Scroller")
        self:SetFakeParent(scr)

        -- move choices on screen
        -- we set it to start off screen using the metrics
        scr:smooth(animationSeconds)
        scr:x(scrollerX)
    end,
    MenuSelectionChangedMessageCommand = function(self)
        local i = self:GetFakeParent():GetDestinationItem() + 1
        local actorScroller = self:GetFakeParent():GetChild("ScrollChoice"..choiceTable[i])

        self:finishtweening()
        self:smooth(0.05)
        self:y(actorScroller:GetY())
    end,

    Def.Sprite {
        Name = "Fade",
        Texture = THEME:GetPathG("", "selectorFade"),
        BeginCommand = function(self)
            self:x(-selectorHeight)
            self:halign(0)
            self:zoomto(selectorWidth, selectorHeight)
            self:queuecommand("UpdateWidth")
        end,
        UpdateWidthCommand = function(self)
            -- the minimum width is going to be about 10% longer than the longest choice text
            local widest = selectorWidth
            for name, child in pairs(self:GetParent():GetFakeParent():GetChildren()) do
                local w = child:GetChild("ScrollerText"):GetZoomedWidth()
                if w > widest - (selectorHeight * 2) then
                    widest = w + selectorHeight * 2
                end
            end
            if widest ~= selectorWidth then
                widest = widest * 1.1
            end
            self:zoomto(widest, selectorHeight)
        end
    }
}

return t
