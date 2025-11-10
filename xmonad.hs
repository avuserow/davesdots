{-# LANGUAGE OverloadedStrings #-}

import XMonad
import qualified XMonad.StackSet as W

import XMonad.Actions.CycleWS

import XMonad.Layout.Grid
import XMonad.Layout.Tabbed
import XMonad.Layout.NoBorders(smartBorders)
import XMonad.Layout.ResizableTile

import XMonad.Hooks.UrgencyHook
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks

import XMonad.Util.Run(spawnPipe)
import XMonad.Util.EZConfig(additionalKeysP)

import XMonad.Prompt
import XMonad.Prompt.Shell(shellPrompt)
import XMonad.Prompt.Window

import System.IO(hPutStrLn)
import System.Posix.Unistd(getSystemID, nodeName)
import System.Posix.IO(createFile, openFd, OpenMode(..), defaultFileFlags, fdWrite)
import System.FilePath(FilePath)

import Control.Monad(void)
import qualified Codec.Binary.UTF8.String as UTF8

import qualified DBus as D
import qualified DBus.Client as D

-- Things that should always float
myFloatHook = composeAll
	[ className =? "qemu" --> doFloat
	, title =? "xfce4-notifyd" --> doIgnore
	, title =? "xfce4-panel" --> doIgnore
	, title =? "Mini Metro" --> doIgnore
	, className =? "xfdesktop" --> doIgnore
	]

myLayoutHook = avoidStruts (tiled ||| Grid ||| simpleTabbed)
	where
		-- default tiling algorithm partitions the screen into two panes
		tiled   = ResizableTall nmaster delta ratio []

		-- The default number of windows in the master pane
		nmaster = 1

		-- Default proportion of screen occupied by master pane
		ratio   = 1/2

		-- Percent of screen to increment by when resizing panes
		delta   = 3/100

getHostKey :: String -> KeyMask
getHostKey hostname =
	if hostname `elem` ["goldbug", "walrus", "whisper", "beaujolais", "urbania"] then mod4Mask
	else mod1Mask

myXPConfig = def
	{ position          = Top
	, alwaysHighlight   = True
	, promptBorderWidth = 0
	, height            = 24
	, font              = "xft:monospace:size=11"
	}

main = do
	dbus <- D.connectSession
	getWellKnownName dbus
	host <- fmap nodeName getSystemID -- TODO: make me mighty
	--pipe <- openFd "/tmp/ak.log" WriteOnly Nothing defaultFileFlags
	-- pipe <- createFile "/tmp/ak.log" 0600
	xmonad $ withUrgencyHook NoUrgencyHook $ docks def
			{ manageHook = manageDocks <+> myFloatHook <+> manageHook def
			, modMask = getHostKey host
			, layoutHook = avoidStruts $ smartBorders $ myLayoutHook
			, logHook = dynamicLogWithPP def
				{ ppOutput = dbusOutput dbus
				, ppUrgent = pangoColor "#FF0000" . wrap "**" "**" . pangoSanitize
				, ppVisible = wrap "&lt;" "&gt;"
				, ppTitle  = wrap "" "" . pangoColor "#8AE234" . pangoSanitize
				}
			}
			`additionalKeysP`
			[ ("M-p", shellPrompt myXPConfig)
			, ("M-S-p", spawn "rofi --show run")
			, ("M-S-a", windowPrompt myXPConfig Goto allWindows)
			, ("M-a", windowPrompt myXPConfig Bring allWindows)
			, ("M-S-l", spawn "~/bin/lock")
			, ("M-S-q", spawn "xfce4-session-logout")
			, ("M-S-\\", spawn "~/bin/auto-xterm")
			, ("M-S-\'", spawn "xfce4-terminal")
			, ("M-v", spawn "~/bin/clipboard-paste-emu")
			, ("M-<Left>", moveTo Prev (hiddenWS :&: Not emptyWS))
			, ("M-S-<Left>", shiftToPrev)
			, ("M-<Right>", moveTo Next (hiddenWS :&: Not emptyWS))
			, ("M-S-<Right>", shiftToNext)
			, ("M-<Up>", windows W.focusUp)
			, ("M-S-<Up>", windows W.swapUp)
			, ("M-<Down>", windows W.focusDown)
			, ("M-S-<Down>", windows W.swapDown)
			, ("M-S-t", withFocused $ \w -> floatLocation w >>= windows . W.float w . snd)
			, ("M-`", toggleWS)
			, ("M-s", moveTo Next emptyWS)
			, ("M-S-s", shiftTo Next emptyWS)
			, ("M-[", sendMessage MirrorExpand)
			, ("M-]", sendMessage MirrorShrink)
			, ("M-b", sendMessage ToggleStruts)
			]

getWellKnownName :: D.Client -> IO ()
getWellKnownName dbus = do
  D.requestName dbus (D.busName_ "org.xmonad.Log")
                [D.nameAllowReplacement, D.nameReplaceExisting, D.nameDoNotQueue]
  return ()

dbusOutput :: D.Client -> String -> IO ()
dbusOutput dbus str = do
    let signal = (D.signal "/org/xmonad/Log" "org.xmonad.Log" "Update") {
            D.signalBody = [D.toVariant ("<b>" ++ str ++ "</b>")]
        }
    D.emit dbus signal

pangoColor :: String -> String -> String
pangoColor fg = wrap left right
	where
		left  = "<span foreground=\"" ++ fg ++ "\">"
		right = "</span>"

pangoSanitize :: String -> String
pangoSanitize = foldr sanitize ""
	where
		sanitize '>'  xs = "&gt;" ++ xs
		sanitize '<'  xs = "&lt;" ++ xs
		sanitize '\"' xs = "&quot;" ++ xs
		sanitize '&'  xs = "&amp;" ++ xs
		sanitize x    xs = x:xs
