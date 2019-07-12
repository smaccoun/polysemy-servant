module Effects
  (runAllIO
  ,runEffects
  ,module Polysemy.Operators
  ,Db
  ,runSql
  ) where

import AppBase hiding (Reader, runReader)
import Effects.Logging
import Effects.DB (Db, runDbIO, runSql)
import Config
import Polysemy
import Polysemy.Reader
import Polysemy.Operators

runEffects :: Config -> Sem '[Reader Config, Db, Log, Lift IO] a -> IO a
runEffects config a = do
  runAllIO config a

runAllIO :: Config -> Sem '[Reader Config, Db, Log, Lift IO] a -> IO a
runAllIO config@Config{..} = do
  runM
  . runLogStdOut
  . runDbIO dbPool
  . runReader config
