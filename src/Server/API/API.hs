module Server.API.API where

import           AppBase
import           Servant.API
import           Servant.Server
import Entities
import Effects
import Effects.DSL.CrudAPI
import Polysemy

type API =
    "blog_post" :>
      (    Get '[JSON] [BlogPost]
      :<|> Capture "blogPostId" Int64 :> Get '[JSON] (Maybe BlogPost)
      :<|> ReqBody '[JSON] [BlogPost] :> Post '[JSON] [Int64]
      )

api :: Proxy API
api = Proxy

apiServer :: ServerT API (Sem AllAppEffects)
apiServer =
       getEntities (Proxy @BlogPost) [] []
  :<|> getByEntityId BlogPostId
  :<|> createEntities
