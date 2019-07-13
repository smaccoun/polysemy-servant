module Generate where

import AppBase
import           Language.PureScript.Bridge
import Entities
import Config
import Database.Persist.Postgresql (withPostgresqlConn)
import Database.Persist.Sql
import Control.Monad.Logger (runStdoutLoggingT, MonadLogger(..))
import Control.Monad.Trans.Resource (runResourceT)
import Control.Monad.IO.Unlift
import Control.Monad.Reader (runReaderT)

writeFrontendTypes :: IO ()
writeFrontendTypes = writePSTypes "./psTypes.purs"
                                  (buildBridge defaultBridge)
                                  [ mkSumType (Proxy :: Proxy BlogPost) ]

myTypes :: [SumType Haskell]
myTypes = [ mkSumType (Proxy @BlogPost) ]


genLocalMigration :: IO ()
genLocalMigration = do
  context <- liftIO $ readContext
  let conn = dbConnString $ dbConfig context
  runResourceT $ runStdoutLoggingT $ withConnShowMigration conn
  where
    withConnShowMigration conn' =
      withPostgresqlConn conn' withBackendShowMigration

    withBackendShowMigration :: (MonadUnliftIO m) => SqlBackend -> m ()
    withBackendShowMigration sqlBackend' =
      flip runReaderT sqlBackend' $ printMigration migrateAll
