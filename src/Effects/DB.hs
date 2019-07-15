module Effects.DB where

import AppBase
import Polysemy
import Data.Pool (Pool)
import Database.Persist.Sql (SqlBackend)
import qualified Database.Persist.Sql as P
import Database.Persist hiding (insert)

type CommonRecordConstraint record = (PersistQueryRead SqlBackend, PersistEntityBackend record ~ BaseBackend SqlBackend, PersistEntity record, ToBackendKey SqlBackend record)

data Db m a where
  RunSql ::  forall a m. ReaderT SqlBackend IO a -> Db m a
  GetEntitiesById :: (CommonRecordConstraint record) => [Filter record] -> [SelectOpt record] -> Db m [Entity record]
  GetEntityById :: CommonRecordConstraint record => EntityField record (Key record) -> Int64 -> Db m (Maybe (P.Entity record))
  InsertEntities :: CommonRecordConstraint record => [record] -> Db m [Key record]
  ReplaceEntity  :: CommonRecordConstraint record => Key record -> record -> Db m ()

makeSem ''Db

runDbIO :: forall r a. Member (Lift IO) r
        => Pool SqlBackend
        -> Sem (Db ': r) a
        -> Sem r a
runDbIO pool' = interpret $ \case
  RunSql sql' -> runQ sql'
  GetEntitiesById withMatchingFilters andSelectOptions -> runQ $
    selectList withMatchingFilters andSelectOptions
  GetEntityById recordIdCon idVal -> runQ $
    selectFirst [recordIdCon ==. P.toSqlKey idVal] []
  InsertEntities vals' -> runQ $ insertMany vals'
  ReplaceEntity key' newRecord -> runQ $ replace key' newRecord
  where
    runQ :: ReaderT SqlBackend IO v -> Sem r v
    runQ q = sendM $ runPool q

    runPool :: ReaderT SqlBackend IO v -> IO v
    runPool = runSqlIO pool'

runSqlIO :: Pool SqlBackend -> ReaderT SqlBackend IO a -> IO a
runSqlIO pool' sql' = P.runSqlPool sql' pool'


