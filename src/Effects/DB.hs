module Effects.DB where

import AppBase
import Polysemy
import Data.Pool (Pool)
import Database.Persist.Sql (SqlBackend)
import qualified Database.Persist.Sql as P
import Database.Persist

data Db m a where
  RunSql ::  forall a m. ReaderT SqlBackend IO a -> Db m a
  GetById :: forall record m. (PersistQueryRead SqlBackend, PersistEntityBackend record ~ BaseBackend SqlBackend, ToBackendKey SqlBackend record)
          => EntityField record (Key record) -> Int64 -> Db m (Maybe (P.Entity record))

makeSem ''Db

runDbIO :: Member (Lift IO) r
        => Pool SqlBackend
        -> Sem (Db ': r) a
        -> Sem r a
runDbIO pool' = interpret $ \case
  RunSql sql' -> sendM $ runSqlIO pool' sql'
  GetById recordIdCon idVal -> sendM $ runQ $
    selectFirst [recordIdCon ==. P.toSqlKey idVal] []
  where
    runQ :: ReaderT SqlBackend IO v -> IO v
    runQ = runSqlIO pool'

runSqlIO :: Pool SqlBackend -> ReaderT SqlBackend IO a -> IO a
runSqlIO pool' sql' = P.runSqlPool sql' pool'
