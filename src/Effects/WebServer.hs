module Effects.WebServer where

import AppBase hiding (Reader, runReader)
import Config
import Polysemy
import Polysemy.Operators
import Polysemy.Error
import Effects.Logging
import Servant.Server (Handler(..), runHandler, ServantErr(..), Application)
import Config (Config(..))
import qualified Network.Wai.Handler.Warp as Web
import Servant.Server (ServantErr)

data WebServer m a where
  RunServer :: Int -> Application -> WebServer m ()

makeSem ''WebServer

--logServerExceptions :: Members '[Log, Lift IO] r => Sem ((Error ServantErr) ': r) a -> Sem r (Either ServantErr a)
--logServerExceptions effs = catch effs onServantError
--  where
--    onServantError :: Members '[Lift IO] r => ServantErr -> Sem r a
--    onServantError e = do
--      runLogStdOut $ log $ show e
--      throw e

runServerIO :: Members '[Lift IO] r => Sem (WebServer ': r) a -> Sem r a
runServerIO = interpret $ \case
  RunServer port' webApp -> sendM $ Web.run port' webApp
