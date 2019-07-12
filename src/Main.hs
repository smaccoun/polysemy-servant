module Main where

import           AppBase
import           Polysemy
import           Server.Serve    ( runServer )
import Effects
import Effects.Logging (log)
import Effects.DB
import Control.Monad.Logger (runStdoutLoggingT)
import Control.Monad.Trans.Resource (runResourceT)
import Config (initConfig)
import qualified Database.Persist.Sql as P
import Entities

main :: IO ()
main = do
    let startMsg = "Starting up server" :: Text
    runResourceT $ runStdoutLoggingT $ do
      config <- runResourceT $ runStdoutLoggingT $ initConfig
      liftIO $ runEffects config $ do
        log startMsg
        runSql $ (P.rawSql @(P.Entity BlogPost)) "SELECT * FROM blog LIMIT 10" []
        sendM runServer
