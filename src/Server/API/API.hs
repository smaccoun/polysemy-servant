module Server.API.API where

import           AppBase
import           Servant.API
import           Servant.Server
import Entities
import Effects
import Effects.DB
import Polysemy
import Database.Persist (Entity(..))
import Server.CRUDServer

type API = EntityCrudAPI "blogPost" "blogPostId" BlogPost

api :: Proxy API
api = Proxy

apiServer :: ServerT API (Sem AllAppEffects)
apiServer =
  crudEntityServer (Proxy @BlogPost) (BlogPostId)
