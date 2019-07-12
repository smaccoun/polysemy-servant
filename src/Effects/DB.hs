module Effects.DB where

import AppBase
import Polysemy
import Data.Pool (Pool)
import Data.Pool
import Database.Persist.Sql (PersistValue, SqlBackend)
import qualified Database.Persist.Sql as P

data Db m a where
  RunSql ::  forall a m. ReaderT SqlBackend IO a -> Db m a
--  RawSql :: forall a m. Text -> [PersistValue] -> Db m a

makeSem ''Db

runDbIO :: forall a r. Member (Lift IO) r => Pool SqlBackend -> Sem (Db ': r) a -> Sem r a
runDbIO pool' = interpret $ \case
  RunSql sql' -> sendM $ runSqlIO pool' sql'

runSqlIO :: Pool SqlBackend -> ReaderT SqlBackend IO x -> IO x
runSqlIO pool' sql' = P.runSqlPool sql' pool'
