module Main where

import           AppBase
import Server.Serve (runServer)
import Config (initConfig, Config(..))
import Control.Monad.Logger (runStdoutLoggingT, logInfoN, MonadLogger(..))
import Control.Monad.Trans.Resource (runResourceT)
import Control.Monad.IO.Unlift

main :: IO ()
main = do
  runResourceT $ runStdoutLoggingT $ do
    config <- initConfig
    logInfoN "Config loaded. Starting server"
    liftIO $ runServer config
