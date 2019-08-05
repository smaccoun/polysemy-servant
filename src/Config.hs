module Config where

import           AppBase                     hiding ( intercalate )

import qualified Configuration.Dotenv        as Dotenv

import           Control.Exception
import           Control.Monad.IO.Unlift
import           Control.Monad.Logger

import           Data.Pool                   ( Pool(..) )

import           Database.Persist.Postgresql ( ConnectionString
                                             , createPostgresqlPool
                                             )
import           Database.Persist.Sql        ( SqlBackend )
import qualified Database.PostgreSQL.Simple  as PG

import           Dhall

import           System.Environment          ( setEnv )

data Context = Context { env      :: Environment
                       , dbConfig :: DBConnectInfo
                       }
    deriving ( Generic, Show )

data Config = Config { dbPool :: Pool SqlBackend
                     }

readContext :: IO Context
readContext = do
    _ <- loadDotEnvIfExists
    input auto "./config/config.dhall"

loadDotEnvIfExists :: IO ()
loadDotEnvIfExists = do
    extraEnvs
        <- liftIO $ try @SomeException $ Dotenv.loadFile Dotenv.defaultConfig
    case extraEnvs of
        Right eenvs -> forM_ eenvs $ \(ename, evalue) -> setEnv ename evalue
        Left e -> print "No dotenv file"

initConfig :: (MonadLogger m, MonadUnliftIO m) => m Config
initConfig = do
    context@Context{..} <- liftIO readContext
    pool' <- createPostgresqlPool (dbConnString dbConfig) 1
    return $ Config { dbPool = pool'
                    }

dbConnString :: DBConnectInfo -> ConnectionString
dbConnString dbConn = PG.postgreSQLConnectionString $ pgConnectInfo dbConn

pgConnectInfo :: DBConnectInfo -> PG.ConnectInfo
pgConnectInfo DBConnectInfo{..} =
    PG.ConnectInfo { connectHost     = toString dbConnectHost
                   , connectPort     = fromInteger dbConnectPort
                   , connectUser     = toString dbConnectUser
                   , connectPassword = toString dbConnectPassword
                   , connectDatabase = toString dbConnectDatabase
                   }

data Environment = Development | Production | Test
    deriving ( Generic, Show )

data DBConnectInfo = DBConnectInfo { dbConnectHost     :: Text
                                   , dbConnectPort     :: Integer
                                   , dbConnectDatabase :: Text
                                   , dbConnectUser     :: Text
                                   , dbConnectPassword :: Text
                                   }
    deriving ( Generic, Show )

instance Interpret Environment

instance Interpret Context

instance Interpret DBConnectInfo
