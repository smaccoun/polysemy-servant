let Env = < Development | Production | Test >
in
  let mkDBConfig = ./dbConfig.dhall
  in
      let curEnv = Env.Development
      in
        { env = curEnv
        , dbConfig = merge mkDBConfig curEnv
        , awsAccessKey = env:AWS_ACCESS_KEY as Text
        , awsSecretKey = env:AWS_SECRET_KEY as Text
        }
