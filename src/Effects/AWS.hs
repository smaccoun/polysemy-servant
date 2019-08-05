module Effects.AWS where

import AppBase hiding (Reader(..), ask)
import Network.AWS
import Config (Config(..))
import Polysemy
import Polysemy.Reader

data Aws m a where
  RunAws :: AWS a -> Aws m a

makeSem ''Aws

runAwsIO :: Members '[Lift IO, Reader Config] r => Sem (Aws ': r) a -> Sem r a
runAwsIO = interpret $ \case
  RunAws awsCmd' -> do
    Config{..} <- ask
    sendM $ liftIO
      $ runResourceT
      $ runAWS awsEnv
        $ within Oregon
        $ awsCmd'
