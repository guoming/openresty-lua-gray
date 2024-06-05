package.path = package.path .. ";./lua-scripts/?.lua"

local cache=require("cache")
local nginx=require("nginx")
local cjson = require('cjson')

local defaultUpstream="backend"
local url= nginx.get_request_url()
local username  = nginx.get_request_auth_username()

-- [{path:'/helloword',upstream:'backend'},{path:'/hello.*',upstream:'gray_backend'}]
local res,error,gray_all_rule= cache.get("user");

if not res then
    gray_all_rule='[]'
end

-- 设置默认值
if(not gray_all_rule or gray_all_rule == ngx.null) then
    gray_all_rule='[]'
end

ngx.log(ngx.DEBUG,"global rule json=", gray_all_rule)

-- [{path:'/helloword',upstream:'backend'},{path:'/hello.*',upstream:'gray_backend'}]
local res,error,gray_user_rule= cache.get("user:".. username);

if not res then
    gray_user_rule='[]'
end

-- 设置默认值
if(not gray_user_rule or gray_user_rule == ngx.null) then
    gray_user_rule='[]'
end

ngx.log(ngx.DEBUG,"user rule json=", gray_user_rule)

-- 解析JSON字符串为Lua表
local jsonObj_gray_all_rule = cjson.decode(gray_all_rule)
local jsonObj_gray_user_rule = cjson.decode(gray_user_rule)

-- 循环处理规则数组(全局规则优先)
for _, rule in ipairs(jsonObj_gray_all_rule) do

    ngx.log(ngx.DEBUG,"global rule path=", rule.path," backend=", rule.upstream)

    -- 使用 string.match 判断请求路径是否匹配规则
    if url:match(rule.path) then
        ngx.var.target = rule.upstream;
        ngx.var.username = username;

        ngx.header.gray_target= rule.upstream
        ngx.header.gray_rule= 'global'
        return
    else
        print("No match.")
    end
end

-- 循环处理规则数组（用户规则）
for _, rule in ipairs(jsonObj_gray_user_rule) do

    -- 在这里执行您的逻辑，例如打印路径和上游信息
    ngx.log(ngx.DEBUG,"global rule path=", rule.path," upstream=", rule.upstream)

    -- 使用 string.match 判断请求路径是否匹配规则
    if url:match(rule.path) then
        print("Match!")
        ngx.var.target = rule.upstream;
        ngx.var.username = username;

        ngx.header.gray_target= rule.upstream
        ngx.header.gray_rule= 'user'
        return
    else
        print("No match.")
    end
end

-- 兜底走默认
ngx.var.target = defaultUpstream;
ngx.var.username = username;
ngx.header.gray_target= defaultUpstream
ngx.header.gray_rule= 'default'