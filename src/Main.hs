module Main where

import           AppBase

import           Config                       (initConfig)

import           Control.Monad.Logger         (LoggingT (..), logInfoN,
                                               runStdoutLoggingT)
import           Control.Monad.Trans.Resource (ResourceT (..), runResourceT)

import           Server.Serve                 (runServer)

main :: IO ()
main = do
    runApp $ do
        config <- initConfig
        logInfoN "Config loaded. Starting server"
        liftIO $ runServer config

runApp :: LoggingT (ResourceT IO) a -> IO a
runApp = runResourceT . runStdoutLoggingT
