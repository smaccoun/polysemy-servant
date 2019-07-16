module Server.Serve where

import AppBase
import Servant.Server
import Servant (errHTTPCode)
import Server.API.API (apiServer, api)
import Network.Wai.Handler.Warp
import Config
import Polysemy hiding (run)
import Effects
import Control.Monad.Except (throwError, catchError)

webApp :: Config -> Application
webApp config = serve api $ hoistServer api (customHandler config) apiServer

customHandler :: Config -> Sem AllAppEffects a -> Handler a
customHandler config action = catchError handler' errorHandler
  where
    handler' = Handler . ExceptT $ (runServerIO config action)
    errorHandler :: ServantErr -> Handler a
    errorHandler err = errorHandler' err (errHTTPCode err)

    errorHandler' :: ServantErr -> Int -> Handler a
    errorHandler' err _ = throwError err

runServer :: Config -> IO ()
runServer config = run 8080 (webApp config)

apiWithDocsServer :: ServerT ApiWithDocs (Sem AllAppEffects)
apiWithDocsServer =
       sendM (swaggerSchemaUIServer todoSwagger)
  :<|> apiServer
