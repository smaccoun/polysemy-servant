module Effects.AWS where

import AppBase
import Network.AWS
import Config (Config(..))

runAWSIO :: (MonadIO m) => Config -> AWS a -> m a
runAWSIO Config{..} cmd = liftIO $
  runResourceT $ runAWS awsEnv
    $ within Oregon
    $ cmd
