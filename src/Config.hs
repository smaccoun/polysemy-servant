module Config where

import AppBase
import Dhall
import Data.Pool (Pool(..))
import Database.Persist.Sql (SqlBackend)
import Database.Persist.Postgresql (createPostgresqlPool)
import Control.Monad.Logger
import Control.Monad.IO.Unlift

data Context =
  Context
    {env :: Environment
    ,dbConfig :: DBConnectInfo
    } deriving (Generic, Show)

data Config =
  Config
    {dbPool :: Pool SqlBackend}

initConfig :: (MonadLogger m, MonadUnliftIO m) => m Config
initConfig = do
  context@Context{..} <- liftIO $ input auto "./config/config.dhall"
  pool' <- createPostgresqlPool (toConnString dbConfig) 1
  return $
    Config {dbPool = pool'}
  where
    toConnString DBConnectInfo{..} =
     "postgresql://localhost/mydb?user=other&password=secret"


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
