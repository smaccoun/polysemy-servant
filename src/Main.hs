module Main where

import           AppBase
import           Polysemy
import           Server.Serve    ( runServer )
import Effects
import Effects.Logging (log)
import Control.Monad.Logger (runStdoutLoggingT)
import Control.Monad.Trans.Resource (runResourceT)
import Config (initConfig)

main :: IO ()
main = do
    let startMsg = "Starting up server" :: Text
    config <- runResourceT $ runStdoutLoggingT $ initConfig
    runEffects config $ do
      log startMsg
      sendM runServer
