module Config where

import AppBase
import Dhall

data Config =
  Config
    {env :: Environment
    ,dbConfig :: DBConnectInfo
    } deriving (Generic, Show)

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
instance Interpret Config
instance Interpret DBConnectInfo
