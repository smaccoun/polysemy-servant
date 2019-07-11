let Env = < Development | Production | Test >
in
  let mkDBConfig = ./dbConfig.dhall
  in
      let curEnv = Env.Development
      in
        { env = curEnv
        , dbConfig = merge mkDBConfig curEnv
        }
