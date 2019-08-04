module Config where

import AppBase hiding (intercalate)
import Dhall
import Data.Pool (Pool(..))
import Database.Persist.Sql (SqlBackend)
import Database.Persist.Postgresql (createPostgresqlPool, ConnectionString)
import Control.Monad.Logger
import Control.Monad.IO.Unlift
import Control.Monad.Catch
import qualified Database.PostgreSQL.Simple as PG
import qualified Configuration.Dotenv as Dotenv
import System.Environment (setEnv)
import qualified Network.AWS as AWS
import Network.AWS.Data (fromText)
import Control.Lens (preview, _Right)

data Context =
  Context
    {env :: Environment
    ,dbConfig :: DBConnectInfo
    ,awsAccessKey :: AWS.AccessKey
    ,awsSecretKey :: AWS.SecretKey
    } deriving (Generic)

data Config =
  Config
    {dbPool :: Pool SqlBackend
    ,awsEnv :: AWS.Env
    }

readContext :: IO Context
readContext = do
  _ <- loadDotEnvIfExists
  input auto "./config/config.dhall"

loadDotEnvIfExists :: IO ()
loadDotEnvIfExists = do
  extraEnvs <- try @_ @SomeException $ Dotenv.loadFile Dotenv.defaultConfig
  case extraEnvs of
    Right eenvs ->
      forM_ eenvs $ \(ename, evalue) -> setEnv ename evalue
    Left e -> print "No dotenv file"

initConfig :: (MonadLogger m, MonadUnliftIO m, MonadCatch m) => m Config
initConfig = do
  context@Context{..} <- liftIO readContext
  pool' <- createPostgresqlPool (dbConnString dbConfig) 1
  awsEnv' <- AWS.newEnv $ AWS.FromKeys awsAccessKey awsSecretKey
  return $
    Config
      {dbPool = pool'
      ,awsEnv = awsEnv'
      }

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
instance Interpret AWS.AccessKey where
  autoWith o =
    let Type a b = autoWith o
     in Type ((preview _Right . fromText) <=< a) b

instance Interpret AWS.SecretKey where
  autoWith o =
    let Type a b = autoWith o
     in Type ((preview _Right . fromText) <=< a) b
