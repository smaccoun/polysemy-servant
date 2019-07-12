module Server.API.API where

import           AppBase
import           Servant.API
import           Servant.Server
import Entities
import Effects
import Polysemy
import Database.Persist (Entity(..), entityValues)
import Database.Persist.Sql (rawSql)

type API = "post" :> Get '[JSON] BlogPost

sampleBlogPost :: BlogPost
sampleBlogPost =
  BlogPost "howToBeCool" "justBeCoolMan"

type (:!) r a = Members r a

getBlogPosts :: '[Db] >@> [BlogPost]
getBlogPosts = do
  bps <- runSql $ rawSql @(Entity BlogPost) "SELECT * FROM blog_post LIMIT 10" []
  return $ entityVal <$> bps

apiServer :: Server API
apiServer = return sampleBlogPost
