{-# LANGUAGE NoDeriveAnyClass #-}

module Entities where

import AppBase
import           Database.Persist
import           Database.Persist.TH
import Data.Aeson (ToJSON, FromJSON)
import Generic.Random
import Test.QuickCheck
import Test.QuickCheck.Instances
import Data.Validity
import Data.GenValidity.Text
import Data.GenValidity

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
instance FromJSON BlogPost
instance Arbitrary BlogPost where
  arbitrary = genericArbitraryU

instance Validity BlogPost
instance GenUnchecked BlogPost
instance GenValid BlogPost
