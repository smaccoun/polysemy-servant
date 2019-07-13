module Config where

import AppBase hiding (intercalate)
import Dhall
import Data.Pool (Pool(..))
import Database.Persist.Sql (SqlBackend)
import Database.Persist.Postgresql (createPostgresqlPool, ConnectionString)
import Control.Monad.Logger
import Control.Monad.IO.Unlift
import qualified Database.PostgreSQL.Simple as PG

data Context =
  Context
    {env :: Environment
    ,dbConfig :: DBConnectInfo
    } deriving (Generic, Show)

data Config =
  Config
    {dbPool :: Pool SqlBackend}

readContext :: MonadIO m => m Context
readContext =
  liftIO $ input auto "./config/config.dhall"

initConfig :: (MonadLogger m, MonadUnliftIO m) => m Config
initConfig = do
  context@Context{..} <- liftIO readContext
  pool' <- createPostgresqlPool (dbConnString dbConfig) 1
  return $
    Config {dbPool = pool'}

dbConnString :: DBConnectInfo -> ConnectionString
dbConnString dbConn = PG.postgreSQLConnectionString $ pgConnectInfo dbConn

pgConnectInfo :: DBConnectInfo -> PG.ConnectInfo
pgConnectInfo DBConnectInfo{..} =
  PG.ConnectInfo
    {connectHost = toString dbConnectHost
    ,connectPort = fromInteger dbConnectPort
    ,connectUser = toString dbConnectUser
    ,connectPassword = toString dbConnectPassword
    ,connectDatabase = toString dbConnectDatabase
    }

data Environment =
    Development
  | Production
  | Test
  deriving (Generic, Show)

data DBConnectInfo =
  DBConnectInfo
    {dbConnectHost :: Text
    ,dbConnectPort :: Integer
    ,dbConnectDatabase :: Text
    ,dbConnectUser :: Text
    ,dbConnectPassword :: Text
    } deriving (Generic, Show)

instance Interpret Environment
instance Interpret Context
instance Interpret DBConnectInfo
