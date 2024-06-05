local redis = require('resty.redis')
local cjson = require('cjson')
local config = require('config')

local local_cache = ngx.shared.gray
-- 本地缓存过期时间（60秒）
local local_cache_ttl = 60
local redis_pool = {}
local cacheModule={}

local function connect()

    local redisClient = redis:new()

    local ok, err = redisClient:connect(config.REDIS_IP,config.REDIS_PORT)
    if not ok then
        -- 打印日志
        return false, "failed to connect redis"
    end

    redisClient:auth(config.REDIS_AUTH)

    -- --设置redis密码
    -- local count, err = redisClient:get_reused_times()
    -- if 0 == count then
    --     ok, err = redisClient:auth(config.REDIS_AUTH)
    --     if not ok then
    --         return false,"redis failed to auth"
    --     end
    -- elseif err then
    --     return false,"redis failed to get reused times"
    -- end

    --选择redis数据库
    ok, err = redisClient:select(0)
    if not ok then
        return false,"redis connect failed"
    end

    --建立redis连接池
    return true,"success",redisClient
end


local function close(redisClient)
    redisClient:close();
end

function cacheModule.get(key, skip_local_cache)

    -- 获取本地缓存
    local res= local_cache:get(string.upper(key));

    -- 获取本地缓存成功
    if not skip_local_cache and res then

        -- 打印日志
        ngx.log(ngx.DEBUG,"local cache hit: " .. string.upper(key) .. res)

        -- 返回
        return true,"ok",res;

    else

        -- 缓存没有命中，则从redis中获取并设置本地缓存

        local res,err,redisClient = connect();

        if not res then
            return false,err
        end

        local value= redisClient:get(string.upper(key))
        
        close(redisClient)

        --------- --------- --------- --------- --------- ---------
        
        if value and  value ~= ngx.null then
            
            local ok, err = local_cache:set(string.upper(key), value, local_cache_ttl)

            if ok then
                ngx.log(ngx.DEBUG, "local cache set: ", string.upper(key))
            else
                ngx.log(ngx.ERR, "local cache set failed: ", err)
            end

        end
        --------- --------- --------- --------- --------- ---------

        return true,"ok",value;

    end

end


function cacheModule.set(key,value)

    local res,err,redisClient = connect();
    if not res then
        return false,err
    end

    redisClient:set(string.upper(key),value)

    close(redisClient)

    return true,"ok"
end

function cacheModule.del(key)

    local res,err,redisClient = connect();
    if not res then
        return false,err
    end

    redisClient:del(string.upper(key))

    close(redisClient)

    return true,"ok"
end

return cacheModule