module Server.API.API where

import           AppBase
import           Servant.API
import           Servant.Server
import Entities
import Effects
import Polysemy
import Database.Persist (Entity(..), entityValues)
import Database.Persist.Sql (rawSql)

type API = "blog_post" :> Get '[JSON] [BlogPost]

api :: Proxy API
api = Proxy

getBlogPosts :: '[Db] >@> [BlogPost]
getBlogPosts = do
  bps <- runSql $ rawSql @(Entity BlogPost) "SELECT ?? FROM blog_post" []
  return $ entityVal <$> bps

apiServer :: ServerT API (Sem AllAppEffects)
apiServer = getBlogPosts
