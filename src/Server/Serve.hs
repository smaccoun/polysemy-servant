module Server.Serve where

import AppBase
import Servant.Server
import Server.API.API (API, apiServer, api)
import Network.Wai.Handler.Warp
import Config
import Polysemy hiding (run)
import Effects

webApp :: Config -> Application
webApp config = serve api $ hoistServer api (nt config) apiServer

nt :: Config -> Sem AllAppEffects a -> Handler a
nt config action = Handler . ExceptT $ runServerIO config action

runServer :: Config -> IO ()
runServer config = run 8080 (webApp config)
