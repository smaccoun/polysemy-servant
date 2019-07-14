module Server.API.API where

import           AppBase
import           Servant.API
import           Servant.Server
import Entities
import Effects
import Effects.DSL.CrudAPI (getByEntityId, getEntities)
import Polysemy
import Database.Persist (Entity(..))
import Database.Persist.Sql (rawSql, toSqlKey)
import Database.Persist.Types (PersistValue(..))

type API =
       "blog_post" :> Get '[JSON] [BlogPost]
  :<|> "blog_post" :> Capture "blogPostId" Int64 :> Get '[JSON] (Maybe BlogPost)

api :: Proxy API
api = Proxy

apiServer :: ServerT API (Sem AllAppEffects)
apiServer =
       getEntities (Proxy @BlogPost) [] []
  :<|> getByEntityId BlogPostId
