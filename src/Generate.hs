module Generate where

import AppBase
import           Language.PureScript.Bridge
import Language.PureScript.Bridge.PSTypes
import           Servant.PureScript
import Control.Lens
import Entities
import Config
import Database.Persist.Postgresql (withPostgresqlConn)
import Database.Persist.Sql
import Control.Monad.Logger (runStdoutLoggingT, MonadLogger(..))
import Control.Monad.Trans.Resource (runResourceT)
import Control.Monad.IO.Unlift
import Control.Monad.Reader (runReaderT)

data AppBridge

appBridgeParts :: BridgePart
appBridgeParts = defaultBridge

appBridge :: FullBridge
appBridge = buildBridge appBridgeParts

instance HasBridge AppBridge where
  languageBridge _ = appBridge

mySettings :: Settings
mySettings = (addReaderParam "AuthToken" defaultSettings & apiModuleName .~ "Counter.WebAPI")

appTypes :: [SumType 'Haskell]
appTypes = [ mkSumType (Proxy :: Proxy BlogPost) ]

writeFrontendTypes :: IO ()
writeFrontendTypes = writePSTypes "./psTypes.purs" appBridge appTypes

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
