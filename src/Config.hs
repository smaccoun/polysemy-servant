module Config where

import AppBase
import Database.PostgreSQL.Simple (ConnectInfo(..), defaultConnectInfo)
import Dhall

data Config =
  Config
    {env :: Environment
    } deriving (Generic, Show)

data Environment =
    Development
  | Production
  | Test
  deriving (Generic, Show)

instance Interpret Environment
instance Interpret Config


dbConnectInfo :: Environment -> ConnectInfo
dbConnectInfo env =
  case env of
    Development ->
      defaultConnectInfo
        {connectDatabase = "blog"
        , connectPort = 54320
        }
    Production ->
      defaultConnectInfo {connectDatabase = "blog"}
    Test ->
      defaultConnectInfo {connectDatabase = "blog_test"}
