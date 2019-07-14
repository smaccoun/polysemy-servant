{-# LANGUAGE NoDeriveAnyClass #-}

module Entities where

import AppBase
import           Database.Persist
import           Database.Persist.TH
import Data.Aeson (ToJSON)

share [mkPersist sqlSettings, mkMigrate "migrateAll"] [persistLowerCase|
Person
    name Text
    age Int Maybe
    deriving Generic Show

BlogPost
    title Text
    body Text
    deriving Generic Show

Products
    name Text
    price Int
    deriving Generic Show
|]

instance ToJSON BlogPost

