module Effects.WebServer where

import AppBase hiding (Reader, runReader)
import Config
import Polysemy
import Polysemy.Operators
import Servant.Server (Handler(..), runHandler, ServantErr(..), Application)
import Config (Config(..))
import qualified Network.Wai.Handler.Warp as Web

data WebServer m a where
  RunServer :: Int -> Application -> WebServer m ()
  RunLiftedHandler :: Handler a -> WebServer m (Either ServantErr a)

makeSem ''WebServer

runServerIO :: Members '[Lift IO] r => Sem (WebServer ': r) a -> Sem r a
runServerIO = interpret $ \case
  RunLiftedHandler handler' -> sendM $ runHandler handler'
  RunServer port' webApp -> sendM $ Web.run port' webApp
