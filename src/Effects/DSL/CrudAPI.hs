-- | A DSL for highly common CRUD operations served by the API

module Effects.DSL.CrudAPI where

import AppBase
import Polysemy
import Database.Persist
import Effects.DB
import Database.Persist.Sql (fromSqlKey)

data CrudAPI m a where
  GetEntities :: forall record m. CommonRecordConstraint record => Proxy record -> [Filter record] -> [SelectOpt record] -> CrudAPI m [record]
  GetByEntityId :: forall record m. CommonRecordConstraint record
          => EntityField record (Key record) -> Int64 -> CrudAPI m (Maybe record)
  CreateEntities :: forall record m. CommonRecordConstraint record => [record] -> CrudAPI m [Int64]

makeSem ''CrudAPI

runCrudApiIO :: Member Db r
        => Sem (CrudAPI ': r) a
        -> Sem r a
runCrudApiIO = interpret $ \case
  GetEntities _ byMatching selectOptions -> do
    mbEntities <- getEntitiesById byMatching selectOptions
    return $ entityVal <$> mbEntities
  GetByEntityId recordIdCon idVal -> do
    mbEntity <- getEntityById recordIdCon idVal
    return $ entityVal <$> mbEntity
  CreateEntities entities' -> do
    createdKeys <- insertEntities entities'
    return $ fromSqlKey <$> createdKeys
