module Server.API.API where

import           AppBase
import           Servant.API
import           Servant.Server

type API = "post" :> Get '[JSON] Int

--data CrudReq a where
--  MkPostReq :: p -> incoming -> outgoing -> CrudReq (PostReq p incoming outgoing)
--  MkGetReq :: p -> outgoing -> CrudReq (GetReq p outgoing)
--
--type family PostReq (p :: k) (incoming :: Type) (outgoing :: Type) where
--  PostReq p incoming outgoing = p :> ReqBody '[JSON] incoming :> Post '[JSON] outgoing
--
--type family GetReq (p :: k) (a :: Type) where
--  GetReq p a = p :> Get '[JSON] a
apiServer :: Server API
apiServer = return 1
