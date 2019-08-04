module Effects
  (runAllIO
  ,runEffects
  ,module Polysemy.Operators
  ,Db
  ,runSql
  ,AllAppEffects
  ,runServerIO
  ) where

import AppBase hiding (Reader, runReader)
import Effects.Logging
import Effects.DB (Db, runDbIO, runSql)
import Effects.AWS.S3
import Effects.DSL.CrudAPI (runCrudApiIO, CrudAPI(..))
import Polysemy
import Polysemy.Reader
import Polysemy.Error (runError, Error(..))
import Polysemy.Operators
import Config (Config(..))
import Servant.Server (ServantErr)

type AllAppEffects = '[CrudAPI, S3, Db, Error ServantErr, Log, Reader Config, Lift IO]

runServerIO :: Config -> Sem AllAppEffects a -> IO (Either ServantErr a)
runServerIO config@Config{..} =
  runM
  . runReader config
  . runLogStdOut
  . handleServantExceptions config
  . runDbIO dbPool
  . runS3
  . runCrudApiIO

runEffects :: Config -> Sem '[Reader Config, CrudAPI, Db, Log, Lift IO] a -> IO a
runEffects config a = do
  runAllIO config a

runAllIO :: Config -> Sem '[Reader Config, CrudAPI, Db, Log, Lift IO] a -> IO a
runAllIO config@Config{..} = do
  runM
  . runLogStdOut
  . runDbIO dbPool
  . runCrudApiIO
  . runReader config

handleServantExceptions :: Member Log r => Config -> Sem (Error ServantErr ': r) a -> Sem r (Either ServantErr a)
handleServantExceptions config curEffects = do
  res <- runError curEffects
  case res of
    Right a -> return $ Right a
    Left e -> do
      log $ show e
      return $ Left e
