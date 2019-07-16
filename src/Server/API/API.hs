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
import Servant.Swagger
import Servant.Swagger.UI
import Data.Swagger
import Control.Lens

type API = "blog_post" :> Get '[JSON] Int
--       EntityCrudAPI "blogPost" "blogPostId" BlogPost
--  :<|> EntityCrudAPI "product" "productId" Product

api :: Proxy API
api = Proxy

type ApiWithDocs = SwaggerSchemaUI "swagger-ui" "swagger.json" :<|> API

apiWithDocs :: Proxy ApiWithDocs
apiWithDocs = Proxy

apiServer :: ServerT API (Sem AllAppEffects)
apiServer = return 1
--       crudEntityServer (Proxy @BlogPost) (BlogPostId)
--  :<|> crudEntityServer (Proxy @Product) (ProductId)
--  :<|> sendM todoSwagger


-- | Swagger spec for Todo API.
todoSwagger :: Swagger
todoSwagger = toSwagger api
  & info.title   .~ "Todo API"
  & info.version .~ "1.0"
  & info.description ?~ "This is an API that tests swagger integration"
  & info.license ?~ ("MIT" & url ?~ URL "http://mit.com")

type SwaggerAPI = "swagger.json" :> Get '[JSON] Swagger

