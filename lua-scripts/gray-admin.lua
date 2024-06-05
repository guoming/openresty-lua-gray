package.path = package.path .. ";./lua-scripts/?.lua"

local cache=require("cache")
local nginx=require("nginx")

local request_method =nginx.get_request_method()
local request_url =nginx.get_request_url()

ngx.header.content_type="application/json;charset=utf-8"

-- 查询缓存
if request_method == "GET" then

    local key = nginx.get_request_uri_args("key")
    local res,error,value=cache.get(key,true);

    if not res then
        ngx.say("{\"code\":1,\"data\":\"\",\"message\":\"" .. error .. "\"}")
        return;
    end

    if value and value ~= ngx.null then
        ngx.say("{\"code\":0,\"data\":\"".. value .."\",\"message\":\"ok\"}")
    else
        ngx.say("{\"code\":0,\"data\":\"\",\"message\":\"ok\"}")
    end
end 

-- 修改缓存
if request_method == "POST" then

        local key = nginx.get_request_post_args("key")
        local value = nginx.get_request_post_args("value")

        cache.set(key,value)
      
        local res,error,value=cache.get(key, true);

        if not res then
            ngx.say("{\"code\":1,\"data\":\"\",\"message\":\"" .. error .. "\"}")
            return;
        end

        if value and value ~= ngx.null then
            ngx.say("{\"code\":0,\"data\":\"".. value .."\",\"message\":\"ok\"}")
        else
            ngx.say("{\"code\":0,\"data\":\"\",\"message\":\"ok\"}")
        end
end


-- 删除缓存
if request_method == "DELETE" then


    local key = nginx.get_request_post_args("key")

    local res,error=cache.del(key)
   
    if not res then
        ngx.say("{\"code\":1,\"data\":\"\",\"message\":\"" .. error .. "\"}")
        return;
    end
    
    ngx.say("{\"code\":0,\"data\":\"\",\"message\":\"ok\"}")

end


