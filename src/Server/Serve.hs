module Server.Serve where

import AppBase
import Servant.Server
import Servant (errHTTPCode)
import Server.API.API (apiServer, api)
import qualified Network.Wai.Handler.Warp as Warp
import Config
import qualified Network.Wai as Wai
import Polysemy hiding (run)
import Effects
import Control.Monad.Except (throwError, catchError)

webApp :: Config -> Wai.Application
webApp config = serve api $ hoistServer api (toHandler config) apiServer

toHandler :: Config -> Sem AllAppEffects a -> Handler a
toHandler config action = Handler . ExceptT $ (runServerIO config action)

runServer :: Config -> IO ()
runServer config = Warp.run 8080 (webApp config)
