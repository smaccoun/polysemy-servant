module Effects.Logging where

import           AppBase

import           Polysemy
import           Polysemy.Output

data Log m a where
    Log :: Text -> Log m ()

makeSem ''Log

runLogStdOut :: Member (Lift IO) r => Sem (Log ': r) a -> Sem r a
runLogStdOut = interpret $ \case
    Log t -> sendM $ print t

logStdOut :: Show o => Member (Lift IO) r => Sem (Output o ': r) a -> Sem r a
logStdOut = interpret $ \(Output t) -> sendM $ print t
