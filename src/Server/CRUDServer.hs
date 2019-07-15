module Server.CRUDServer where

import AppBase
import Polysemy
import Database.Persist
import Effects.DB
import Database.Persist.Sql (fromSqlKey)
import qualified Data.Aeson.Extra.Merge as JSON
import Data.Aeson
import           Servant.API
import           Servant.Server
import GHC.TypeLits

type family EntityCrudAPI (root :: Symbol) (byId :: Symbol) (resType :: Type) where
  EntityCrudAPI root byId resType =
    root :>
      (    Get '[JSON] [Entity resType]
      :<|> Capture byId Int64 :> Get '[JSON] (Maybe (Entity resType))
      :<|> ReqBody '[JSON] [resType] :> Post '[JSON] [Key resType]
      )
--data CrudAPI t where
--  Root :: Text -> CrudAPI (Text -> CrudAPI)
--  CrudAPI :: Text -> Text 
--
--type CrudAPI =
--    "blog_post" :>
--      (    Get '[JSON] [Entity BlogPost]
--      :<|> Capture "blogPostId" Int64 :> Get '[JSON] (Maybe (Entity BlogPost))
--      :<|> ReqBody '[JSON] [BlogPost] :> Post '[JSON] [BlogPostId]
--      )


crudEntityServer :: (Member Db r) => (CommonRecordConstraint record) => Proxy record -> EntityField record (Key record) -> ServerT (EntityCrudAPI "blog_post" "blogPostId" record) (Sem r)
crudEntityServer proxyRecord idMatch =
       getEntities proxyRecord [] []
  :<|> getEntityById idMatch
  :<|> insertEntities

--getResEntities :: forall record m. CommonRecordConstraint record => Proxy record -> [Filter record] -> [SelectOpt record] -> '[Db] >@> [record]
--getResEntities proxyRecord byMatching selectOptions -> do
--  mbEntities <- getEntities proxyRecord byMatching selectOptions
--  return $ entityVal <$> mbEntities
--
--getResByEntityId :: forall record m. CommonRecordConstraint record
--        => EntityField record (Key record) -> Int64 -> '[Db] >@> (Maybe record)
--getResByEntityId recordIdCon idVal -> do
--    mbEntity <- getEntityById recordIdCon idVal
--    return $ entityVal <$> mbEntity
--
--createEntities :: forall record m. CommonRecordConstraint record => [record] -> '[Db] >@> [Int64]
--createEntities entities' -> do
--    createdKeys <- insertEntities entities'
--    return $ fromSqlKey <$> createdKeys
