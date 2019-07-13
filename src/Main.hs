module Main where

import           AppBase
import Server.Serve (runServer)
import Config (initConfig, Config(..))
import Control.Monad.Logger (runStdoutLoggingT)
import Control.Monad.Trans.Resource (runResourceT)

main :: IO ()
main = do
    let startMsg = "Starting up server" :: Text
    initConfigThen $ \config ->
      runServer config


initConfigThen :: (Config -> IO ()) -> IO ()
initConfigThen action =
  runResourceT $ runStdoutLoggingT $ do
    config <- initConfig
    liftIO $ action config
