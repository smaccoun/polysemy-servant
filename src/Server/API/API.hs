module Server.API.API where

import           AppBase hiding (Product(..))
import           Servant.API
import           Servant.Server
import Entities
import Effects
import Effects.DB
import Effects.AWS.S3
import Polysemy
import Database.Persist (Entity(..))
import Server.CRUDServer
import Polysemy.Error (throw)
import Network.AWS.S3 (BucketName(..), ObjectKey(..))

type API =
       EntityCrudAPI "blogPost" "blogPostId" BlogPost
  :<|> EntityCrudAPI "product" "productId" Product
  :<|> "test_error" :> Get '[JSON] Int
  :<|> "protected_pic" :> Capture "pic_name" Text :> Get '[JSON] Text

api :: Proxy API
api = Proxy

apiServer :: ServerT API (Sem AllAppEffects)
apiServer =
       crudEntityServer (Proxy @BlogPost) (BlogPostId)
  :<|> crudEntityServer (Proxy @Product) (ProductId)
  :<|> fkTestThrow
  :<|> getProtectedPic

fkTestThrow :: Sem AllAppEffects Int
fkTestThrow = throw $ err500 {errBody = "meow"}

getProtectedPic :: Text -> '[S3] >@> Text
getProtectedPic picName' =
  getPresignedURL (BucketName "fake-bucket") (ObjectKey picName')

