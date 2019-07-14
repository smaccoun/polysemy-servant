module Server.API.API where

import           AppBase
import           Servant.API
import           Servant.Server
import Entities
import Effects
import Effects.DB (getById)
import Polysemy
import Database.Persist (Entity(..))
import Database.Persist.Sql (rawSql, toSqlKey)
import Database.Persist.Types (PersistValue(..))

type API =
       "blog_post" :> Get '[JSON] [BlogPost]
  :<|> "blog_post" :> Capture "blogPostId" Int64 :> Get '[JSON] (Maybe BlogPost)

api :: Proxy API
api = Proxy

getBlogPosts :: '[Db] >@> [BlogPost]
getBlogPosts = do
  bps <- runSql $ rawSql @(Entity BlogPost) "SELECT ?? FROM blog_post" []
  return $ entityVal <$> bps

getBlogPost :: Int64 -> '[Db] >@> Maybe BlogPost
getBlogPost bpId = do
  mbBP <- getById BlogPostId bpId
  return $ entityVal <$> mbBP

apiServer :: ServerT API (Sem AllAppEffects)
apiServer = getBlogPosts :<|> getBlogPost
