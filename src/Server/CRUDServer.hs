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

type family EntityCrudAPI (root :: Symbol) (byId :: Symbol) (record :: Type) where
  EntityCrudAPI root byId record =
    root :>
      (    Get '[JSON] [Entity record]
      :<|> Capture byId Int64 :> Get '[JSON] (Maybe (Entity record))
      :<|> ReqBody '[JSON] [record] :> Post '[JSON] [Key record]
      :<|> Capture byId Int64 :> ReqBody '[JSON] record :> Put '[JSON] ()
      )


crudEntityServer :: (Member Db r, CommonRecordConstraint record)
                 => Proxy record
                 -> EntityField record (Key record)
                 -> ServerT (EntityCrudAPI rootStr captureIdSymbol record) (Sem r)
crudEntityServer proxyRecord idMatch =
       getEntities proxyRecord [] []
  :<|> getEntityById idMatch
  :<|> insertEntities
  :<|> replaceEntity
