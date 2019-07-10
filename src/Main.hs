module Main where

import           AppBase
import           Effects.Logging ( Log(..), log, runLogStdOut )

import           Polysemy
import           Polysemy.Output

import           Server.Serve    ( runServer )
import Effects

main :: IO ()
main = do
    let startMsg = "Starting up server" :: Text
    runEffects $ do
        log startMsg
        sendM runServer
