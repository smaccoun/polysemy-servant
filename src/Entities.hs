{-# LANGUAGE NoDeriveAnyClass #-}

module Entities where

import           AppBase                   hiding ( Product(..) )

import           Data.Aeson
import           Data.GenValidity
import           Data.GenValidity.Text
import qualified Data.HashMap.Strict       as HM
import           Data.Validity

import           Database.Persist
import           Database.Persist.Sql      ( SqlBackend, fromSqlKey )
import           Database.Persist.TH

import           Generic.Random

import           Test.QuickCheck
import           Test.QuickCheck.Instances

share [mkPersist sqlSettings, mkMigrate "migrateAll"] [persistLowerCase|
Person
    name Text
    age Int Maybe
    deriving Generic Show

BlogPost
    title Text
    body Text
    deriving Generic Show

Product
    name Text
    price Int
    deriving Generic Show
|]


instance ToJSON BlogPost
instance FromJSON BlogPost

instance Arbitrary BlogPost where
    arbitrary = genericArbitraryU

instance ToJSON Product
instance FromJSON Product

instance Arbitrary Product where
    arbitrary = genericArbitraryU

instance Validity BlogPost

instance GenUnchecked BlogPost
instance GenValid BlogPost

instance ( PersistQueryRead SqlBackend
         , PersistEntityBackend record ~ BaseBackend SqlBackend
         , PersistEntity record
         , ToBackendKey SqlBackend record
         , ToJSON record
         ) => ToJSON (Entity record) where
    toJSON (Entity key' rec') = case toJSON rec' of
        Object recordObj -> Object $ HM.fromList $
            [ ("id", Number $ fromIntegral $ fromSqlKey key') ]
            <> (HM.toList recordObj)
        _ -> Null -- TODO? This doesnt seem right
