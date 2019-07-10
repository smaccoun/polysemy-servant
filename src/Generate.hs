module Generate where

import AppBase
import           Language.PureScript.Bridge

data BlogPost = BlogPost {id :: Int} deriving (Generic)

writeFrontendTypes :: IO ()
writeFrontendTypes = writePSTypes "./psTypes.purs"
                                  (buildBridge defaultBridge)
                                  [ mkSumType (Proxy :: Proxy BlogPost) ]

myTypes :: [SumType Haskell]
myTypes = [ mkSumType (Proxy @BlogPost) ]
