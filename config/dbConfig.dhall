let DBConfig = 
   { dbConnectHost : Text
   , dbConnectPort : Integer
   , dbConnectDatabase : Text
   , dbConnectUser : Text
   }

let localHost = "localhost"
let defaultPort = Natural/toInteger 5432
let dbConnectDatabase = "blog_post"

let defaultConfig =
      {dbConnectPort = defaultPort
      ,dbConnectDatabase = dbConnectDatabase
      ,dbConnectUser = (env:DB_USER as Text)
      ,dbConnectPassword = (env:DB_PASSWORD as Text)
      }
in
  {Development =
     defaultConfig
     /\
     {dbConnectHost = localHost }
  ,Test =
     defaultConfig
     /\
     {dbConnectHost = localHost }
  ,Production =
    defaultConfig
    /\
    {dbConnectHost = "madeUpUrl" }
  }

