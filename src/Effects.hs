module Effects where

import AppBase hiding (Reader, runReader)
import Effects.Logging
import Dhall
import Config
import Polysemy
import Polysemy.Reader

runEffects :: Sem '[Reader Config, Log, Lift IO] a -> IO a
runEffects a = do
  config@Config{..} <- input auto "./config.dhall"
  runAllIO config a

runAllIO :: Config -> Sem '[Reader Config, Log, Lift IO] a -> IO a
runAllIO config = do
  runM
  . runLogStdOut
  . runReader config
