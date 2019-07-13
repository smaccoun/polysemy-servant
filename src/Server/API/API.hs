module Server.API.API where

import           AppBase
import           Servant.API
import           Servant.Server
import Entities
import Effects
import Polysemy
import Database.Persist (Entity(..), entityValues)
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
  bps <- runSql $ rawSql @(Entity BlogPost) "SELECT ?? FROM blog_post WHERE id=?" [PersistInt64 bpId]
  return $
    nonEmpty bps
    & fmap head
    & fmap entityVal

apiServer :: ServerT API (Sem AllAppEffects)
apiServer = getBlogPosts :<|> getBlogPost
