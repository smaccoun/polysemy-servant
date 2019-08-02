module Main where

import           AppBase
import Server.Serve (runServer)
import Config (initConfig)
import Control.Monad.Logger (runStdoutLoggingT, logInfoN, LoggingT(..))
import Control.Monad.Trans.Resource (runResourceT, ResourceT(..))

main :: IO ()
main = do
  runApp $ do
    config <- initConfig
    logInfoN "Config loaded. Starting server"
    liftIO $ runServer config

runApp :: LoggingT (ResourceT IO) a
        -> IO a
runApp = runResourceT . runStdoutLoggingT
