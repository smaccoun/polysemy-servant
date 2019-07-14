module Effects.DB where

import AppBase
import Polysemy
import Data.Pool (Pool)
import Database.Persist.Sql (SqlBackend)
import qualified Database.Persist.Sql as P
import Database.Persist

type CommonRecordConstraint record = (PersistQueryRead SqlBackend, PersistEntityBackend record ~ BaseBackend SqlBackend, PersistEntity record)

type ByIdConstraint record = (CommonRecordConstraint record, ToBackendKey SqlBackend record)

data Db m a where
  RunSql ::  forall a m. ReaderT SqlBackend IO a -> Db m a
  GetEntitiesById :: (CommonRecordConstraint record) => [Filter record] -> [SelectOpt record] -> Db m [Entity record]
  GetEntityById :: ByIdConstraint record => EntityField record (Key record) -> Int64 -> Db m (Maybe (P.Entity record))

makeSem ''Db

runDbIO :: Member (Lift IO) r
        => Pool SqlBackend
        -> Sem (Db ': r) a
        -> Sem r a
runDbIO pool' = interpret $ \case
  RunSql sql' -> sendM $ runSqlIO pool' sql'
  GetEntitiesById withMatchingFilters andSelectOptions -> sendM $ runQ $
    selectList withMatchingFilters andSelectOptions
  GetEntityById recordIdCon idVal -> sendM $ runQ $
    selectFirst [recordIdCon ==. P.toSqlKey idVal] []
  where
    runQ :: ReaderT SqlBackend IO v -> IO v
    runQ = runSqlIO pool'

runSqlIO :: Pool SqlBackend -> ReaderT SqlBackend IO a -> IO a
runSqlIO pool' sql' = P.runSqlPool sql' pool'


