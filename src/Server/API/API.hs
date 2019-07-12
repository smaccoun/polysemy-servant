module Server.API.API where

import           AppBase
import           Servant.API
import           Servant.Server
import Entities

type API = "post" :> Get '[JSON] BlogPost

sampleBlogPost =
  BlogPost "howToBeCool" "justBeCoolMan"

apiServer :: Server API
apiServer = return sampleBlogPost
