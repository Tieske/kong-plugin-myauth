#!/bin/bash

kong stop
kong migrations bootstrap --force
kong start

http :8001/services name=myservice url=http://httpbin.org/anything
http :8001/services/myservice/routes paths[]=/
http :8001/services/myservice/plugins name=myauth
http :8001/consumers username=tieske

# "my-auth" is the "daos.lua" key "admin_api_nested_name"
http :8001/consumers/tieske/my-auth key=42

# "my-auths" is the "daos.lua" key "admin_api_name"
http :8001/my-auths

kong config db_export /kong-plugin/kong.yml
