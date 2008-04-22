{-- snippet all --}
-- ch23/PodMain.hs

module Main where

import PodDownload
import PodDB
import PodTypes
import System.Environment
import Database.HDBC
import Network.Socket(withSocketsDo)

import Graphics.UI.Gtk
import Graphics.UI.Gtk.Glade

data GUI = GUI {
      mainWin :: Window,
      mwAddBt :: Button,
      mwUpdateBt :: Button,
      mwDownloadBt :: Button,
      mwFetchBt :: Button,
      mwExitBt :: Button,
      statusWin :: Dialog,
      swOKBt :: Button,
      swCancelBt :: Button,
      swLabel :: Label}

-- import Paths_Pod(getDataFileName)

main = withSocketsDo $ handleSqlError $
    do initGUI                  -- Initialize GTK engine
       gui <- loadGlade
       connectGui gui
       
       args <- getArgs
       dbh <- connect "pod.db"
       case args of
         ["add", url] -> add dbh url
         ["update"] -> update dbh
         ["download"] -> download dbh
         ["fetch"] -> do update dbh
                         download dbh
         _ -> syntaxError
       disconnect dbh

loadGlade =
    do Just xml <- xmlNew "podresources.glade"

       -- Load main window
       mw <- xmlGetWidget xml castToWindow "mainWindow"
       -- When the close button is clicked...
                  
       onDestroy mainWin exitApp
       
       -- Load main window buttons

       [mwAdd, mwUpdate, mwDownload, mwFetch, mwExit, swOK, swCancel] <-
           mapM (xmlGetWidget xml castToButton)
           ["addButton", "updateButton", "downloadButton",
            "fetchButton", "exitButton", "okButton", "cancelButton"]
       
       sw <- xmlGetWidget xml castToDialog "statusDialog"
       swl <- xmlGetWidget xml castToLabel "statusLabel"

       return $ GUI mw mwAdd mwUpdate mwDownload mwFetch mwExit
              sw swOK swCancel swl

add dbh url = 
    do addPodcast dbh pc
       commit dbh
    where pc = Podcast {castId = 0, castURL = url}

update dbh = 
    do pclist <- getPodcasts dbh
       mapM_ procPodcast pclist
    where procPodcast pc =
              do putStrLn $ "Updating from " ++ (castURL pc)
                 updatePodcastFromFeed dbh pc

download dbh =
    do pclist <- getPodcasts dbh
       mapM_ procPodcast pclist
    where procPodcast pc =
              do putStrLn $ "Considering " ++ (castURL pc)
                 episodelist <- getPodcastEpisodes dbh pc
                 let dleps = filter (\ep -> epDone ep == False)
                             episodelist
                 mapM_ procEpisode dleps
          procEpisode ep =
              do putStrLn $ "Downloading " ++ (epURL ep)
                 getEpisode dbh ep

syntaxError = putStrLn 
  "Usage: pod command [args]\n\
  \\n\
  \pod add url      Adds a new podcast with the given URL\n\
  \pod download     Downloads all pending episodes\n\
  \pod fetch        Updates, then downloads\n\
  \pod update       Downloads podcast feeds, looks for new episodes\n"
{-- /snippet all --}