local nginxModule={}


-- 获取请求头客户IP
function nginxModule.get_request_client_ip()
        
    -- 客户IP
    local clientIP=ngx.req.get_headers()["X-Real-IP"]

    if clientIP == nil then
    clientIP=ngx.req.get_headers()["x_forwarded_for"]
    end

    if clientIP == nil then
    clientIP=ngx.var.remote_addr
    end

    return clientIP;
end

-- 获取HTTP请求地址
function nginxModule.get_request_url()
        
    -- 获取当前请求的 URL
    local url = ngx.var.uri 

    return url;
end

function nginxModule.get_request_method()
        
    local request_method = ngx.var.request_method 

    return request_method;
end



-- 获取HTTP 请求用户账号
function nginxModule.get_request_auth_username()
    

    local header_authorization = ngx.var.http_authorization

    if header_authorization == nil then
      
        -- ngx.exit(401);

        return "";
    end

    local _, base64_data = string.match(header_authorization, "(%S+)%s+(%S+)")

    -- 解码 Base64 字符串
    local decoded_str= ngx.decode_base64(base64_data)

    if decoded_str then

        -- 使用模式匹配获取用户名和密码
        local username, password = string.match(decoded_str, "(.*):(.*)")  

        if username and password then
            print("Username: " .. username)
            print("Password: " .. password)

            return username
        else
            ngx.say("Invalid format for username and password.")
        end
    else
        ngx.say("Failed to decode Base64 string.")
    end

    return "";
end


-- 获取HTTP请求头
function nginxModule.get_request_header(key)
    -- 用户信息
    local value = ngx.req.get_headers()[key]

    return value
end


-- 获取HTTP请求头
function nginxModule.get_request_post_args(key)

    ngx.req.read_body()
    
    -- 用户信息
    local value = ngx.req.get_post_args()[key]

    return value
end


-- 获取HTTP请求头
function nginxModule.get_request_uri_args(key)
    -- 用户信息
    local value = ngx.req.get_uri_args()[key]

    return value
end

return nginxModule;