module Effects where

import AppBase hiding (Reader, runReader)
import Effects.Logging
import Effects.DB
import Config
import Polysemy
import Polysemy.Reader

runEffects :: Config -> Sem '[Reader Config, Db, Log, Lift IO] a -> IO a
runEffects config a = do
  runAllIO config a

runAllIO :: Config -> Sem '[Reader Config, Db, Log, Lift IO] a -> IO a
runAllIO config@Config{..} = do
  runM
  . runLogStdOut
  . runDbIO dbPool
  . runReader config
