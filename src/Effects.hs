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
import Polysemy
import Polysemy.Reader
import Polysemy.Error (runError, Error(..))
import Polysemy.Operators
import Config (Config(..))
import Servant.Server (ServantErr)

type AllAppEffects = '[Reader Config, Db, Log, Error ServantErr, Lift IO]

runServerIO :: Config -> Sem '[Reader Config, Db, Log, Error ServantErr, Lift IO] a -> IO (Either ServantErr a)
runServerIO config@Config{..} =
  runM
  . runError
  . runLogStdOut
  . runDbIO dbPool
  . runReader config

runEffects :: Config -> Sem '[Reader Config, Db, Log, Lift IO] a -> IO a
runEffects config a = do
  runAllIO config a

runAllIO :: Config -> Sem '[Reader Config, Db, Log, Lift IO] a -> IO a
runAllIO config@Config{..} = do
  runM
  . runLogStdOut
  . runDbIO dbPool
  . runReader config


