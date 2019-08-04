module Main where

import           AppBase
import Server.Serve (runServer)
import Config (initConfig, Config(..))
import Control.Monad.Logger (runStdoutLoggingT, logInfoN, MonadLogger(..), LoggingT(..))
import Control.Monad.Trans.Resource (runResourceT, ResourceT(..))
import Control.Monad.IO.Unlift
import Data.Time.Clock (getCurrentTime)
import Conduit (MonadUnliftIO(..), MonadResource(..))

main :: IO ()
main = do
  runApp $ do
    config <- initConfig
    logInfoN "Config loaded. Starting server"
    liftIO $ runServer config

runApp :: LoggingT (ResourceT IO) a
        -> IO a
runApp = runResourceT . runStdoutLoggingT

