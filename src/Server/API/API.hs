module Server.API.API where

import           AppBase hiding (Product(..))
import           Servant.API
import           Servant.Server
import Entities
import Effects
import Effects.DB
import Polysemy
import Database.Persist (Entity(..))
import Server.CRUDServer
import Polysemy.Error (throw)

type API =
       EntityCrudAPI "blogPost" "blogPostId" BlogPost
  :<|> EntityCrudAPI "product" "productId" Product
  :<|> "test_error" :> Get '[JSON] Int

api :: Proxy API
api = Proxy

apiServer :: ServerT API (Sem AllAppEffects)
apiServer =
       crudEntityServer (Proxy @BlogPost) (BlogPostId)
  :<|> crudEntityServer (Proxy @Product) (ProductId)
  :<|> fkTestThrow

fkTestThrow :: Sem AllAppEffects Int
fkTestThrow = throw $ err500 {errBody = "meow"}
