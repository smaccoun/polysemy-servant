module Effects.AWS.S3 where

import AppBase hiding (Reader(..), ask)
import Network.AWS
import Network.AWS.S3
import Config (Config(..))
import Polysemy
import Polysemy.Reader
import Data.Time.Clock
import Effects.AWS

data S3 m a where
  GetPresignedURL :: BucketName -> ObjectKey -> S3 m Text

makeSem ''S3

runS3 :: Members '[Lift IO, Reader Config] r => Sem (S3 ': r) a -> Sem r a
runS3 = interpret $ \case
  GetPresignedURL b k -> do
    config <- ask
    ts  <- sendM $ getCurrentTime

    let getPresignedUrl' = presignURL ts 30 (getObject b k)
        runCmd = decodeUtf8 <$> runAWSIO config getPresignedUrl'
    sendM $ liftIO $ runCmd



