module Effects.DB where

import AppBase
import Polysemy
import Data.Pool (Pool)
import Database.Persist.Sql (SqlBackend)
import qualified Database.Persist.Sql as P

data Db m a where
  RunSql ::  forall a m. ReaderT SqlBackend IO a -> Db m a

makeSem ''Db

runDbIO :: Member (Lift IO) r => Pool SqlBackend -> Sem (Db ': r) a -> Sem r a
runDbIO pool' = interpret $ \case
  RunSql sql' -> sendM $ runSqlIO pool' sql'
  where
    runQ = runSqlIO pool'

runSqlIO :: Pool SqlBackend -> ReaderT SqlBackend IO a -> IO a
runSqlIO pool' sql' = P.runSqlPool sql' pool'
