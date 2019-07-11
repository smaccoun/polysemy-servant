module Effects where

import AppBase hiding (Reader, runReader)
import Effects.Logging
import Dhall
import Config
import Polysemy
import Polysemy.Reader

runEffects :: Sem '[Reader Config, Log, Lift IO] a -> IO a
runEffects a = do
  config@Config{..} <- input auto "./config/config.dhall"
  case env of
    Development ->
      runIO config a
    _ ->
      runIO config a

runIO :: Config -> Sem '[Reader Config, Log, Lift IO] a -> IO a
runIO config = do
  runM
  . runLogStdOut
  . runReader config
