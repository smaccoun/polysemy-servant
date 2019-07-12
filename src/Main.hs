module Main where

import           AppBase
import Server.Serve (runServer)
import Effects.Logging (log)
import Control.Monad.Logger (runStdoutLoggingT)
import Control.Monad.Trans.Resource (runResourceT)
import Config (initConfig)

main :: IO ()
main = do
    let startMsg = "Starting up server" :: Text
    runResourceT $ runStdoutLoggingT $ do
      config <- initConfig
      liftIO $ runServer config
