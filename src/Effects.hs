module Effects
    ( runAllIO
    , runEffects
    , module Polysemy.Operators
    , Db
    , runSql
    , AllAppEffects
    , runServerIO
    ) where

import           AppBase             hiding ( Reader, runReader )

import           Config              ( Config(..) )

import           Effects.DB          ( Db, runDbIO, runSql )
import           Effects.DSL.CrudAPI ( CrudAPI(..), runCrudApiIO )
import           Effects.Logging

import           Polysemy
import           Polysemy.Error      ( Error(..), runError )
import           Polysemy.Operators
import           Polysemy.Reader

import           Servant.Server      ( ServantErr )

type AllAppEffects =
    '[Reader Config, CrudAPI, Db, Error ServantErr, Log, Lift IO]

runServerIO :: Config
    -> Sem '[Reader Config, CrudAPI, Db, Error ServantErr, Log, Lift IO] a
    -> IO (Either ServantErr a)
runServerIO config@Config{..} =
    runM . runLogStdOut . handleServantExceptions config . runDbIO dbPool
    . runCrudApiIO . runReader config

runEffects
    :: Config -> Sem '[Reader Config, CrudAPI, Db, Log, Lift IO] a -> IO a
runEffects config a = do
    runAllIO config a

runAllIO :: Config -> Sem '[Reader Config, CrudAPI, Db, Log, Lift IO] a -> IO a
runAllIO config@Config{..} = do
    runM . runLogStdOut . runDbIO dbPool . runCrudApiIO . runReader config

handleServantExceptions :: Member Log r => Config
    -> Sem (Error ServantErr ': r) a -> Sem r (Either ServantErr a)
handleServantExceptions config curEffects = do
    res <- runError curEffects
    case res of
        Right a -> return $ Right a
        Left e -> do
            log $ show e
            return $ Left e
