module Server.API.API where

import           AppBase
import           Servant.API
import           Servant.Server
import Entities
import Effects
import Effects.DB
import Polysemy
import Database.Persist (Entity(..))

type API =
    "blog_post" :>
      (    Get '[JSON] [Entity BlogPost]
      :<|> Capture "blogPostId" Int64 :> Get '[JSON] (Maybe (Entity BlogPost))
      :<|> ReqBody '[JSON] [BlogPost] :> Post '[JSON] [BlogPostId]
      )

api :: Proxy API
api = Proxy

apiServer :: ServerT API (Sem AllAppEffects)
apiServer =
       getEntities (Proxy @BlogPost) [] []
  :<|> getEntityById BlogPostId
  :<|> insertEntities
