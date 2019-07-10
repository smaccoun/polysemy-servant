let Env = < Development : {} | Production : {} | Test : {} >
in let config =
 { env = Env.Development {=}
 }
in
  config
