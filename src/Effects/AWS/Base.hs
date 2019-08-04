-- | Common functions for all aws cmds

module Effects.AWS.Base where

import Prelude
import Network.AWS
import Network.AWS.S3
import Control.Monad.IO.Unlift
import Control.Monad.Trans.Resource (MonadResource(..), runResourceT)
import Config (Config(..))

runAWSIO :: (MonadResource m, MonadUnliftIO m) => Config -> AWS a -> m a
runAWSIO Config{..} cmd =
  runResourceT $ runAWS awsEnv
    $ within Oregon
    $ cmd

