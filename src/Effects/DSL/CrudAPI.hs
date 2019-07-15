-- | A DSL for highly common CRUD operations served by the API

module Effects.DSL.CrudAPI where

import AppBase
import Polysemy
import Database.Persist
import Effects.DB
import Database.Persist.Sql (fromSqlKey)
import qualified Data.Aeson.Extra.Merge as JSON
import Data.Aeson


data CrudAPI m a where
  GetResEntities :: forall record m. CommonRecordConstraint record => Proxy record -> [Filter record] -> [SelectOpt record] -> CrudAPI m [record]
  GetResByEntityId :: forall record m. CommonRecordConstraint record
          => EntityField record (Key record) -> Int64 -> CrudAPI m (Maybe record)
  CreateEntities :: forall record m. CommonRecordConstraint record => [record] -> CrudAPI m [Int64]

makeSem ''CrudAPI

runCrudApiIO :: Member Db r
        => Sem (CrudAPI ': r) a
        -> Sem r a
runCrudApiIO = interpret $ \case
  GetResEntities proxyRecord byMatching selectOptions -> do
    mbEntities <- getEntities proxyRecord byMatching selectOptions
    return $ entityVal <$> mbEntities
  GetResByEntityId recordIdCon idVal -> do
    mbEntity <- getEntityById recordIdCon idVal
    return $ entityVal <$> mbEntity
  CreateEntities entities' -> do
    createdKeys <- insertEntities entities'
    return $ fromSqlKey <$> createdKeys

data WithID baseData =
  WithID
    {entityId :: Int64
    ,baseData :: baseData
    }

instance (CommonRecordConstraint baseData, ToJSON baseData) => ToJSON (WithID baseData) where
  toJSON (WithID id' baseData) = JSON.lodashMerge (toJSON id') (toJSON baseData)
