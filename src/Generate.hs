module Generate where

import AppBase
import           Language.PureScript.Bridge
import Entities

writeFrontendTypes :: IO ()
writeFrontendTypes = writePSTypes "./psTypes.purs"
                                  (buildBridge defaultBridge)
                                  [ mkSumType (Proxy :: Proxy BlogPost) ]

myTypes :: [SumType Haskell]
myTypes = [ mkSumType (Proxy @BlogPost) ]
