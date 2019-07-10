module Server.Serve where

import AppBase
import Servant.Server
import Server.API.API (API, apiServer)
import Network.Wai.Handler.Warp

webApp :: Application
webApp = serve (Proxy @API) apiServer

runServer :: IO ()
runServer = run 8081 webApp
