-- ENRIQUE FREE V55 Encrypted
local k="nvWfpmF9/SpPLiv9AbuPuT/oxVfH7ErmJ56yUeQNYTM="
local sk=""
for i=1,#k do sk=sk..string.char(string.byte(k,i)) end
-- base64 decode key
local function b64d(s)
local b="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
s=s:gsub("[^"..b.."]","")
local r={}
local n=0
for i=1,#s do
local c=s:sub(i,i)
if c=="=" then break end
local v=b:find(c)-1
n=n*64+v
if i%4==0 or i==#s then
local bytes={}
for j=2,0,-1 do
bytes[#bytes+1]=n/(2^(j*8))%256
end
for _,byte in ipairs(bytes) do
r[#r+1]=string.char(byte)
end
n=0
end
end
return table.concat(r)
end
-- fetch encrypted data
local sd=game:HttpGet("https://raw.githubusercontent.com/azabyssal-maker/ENRIQUE-A/main/enrique_data.bin",true)
local sk=b64d(k)
local o={}
for i=1,#sd do
local b=string.byte(sd,i)
local a=string.byte(sk,((i-1)%#sk)+1)
o[i]=string.char(b~a)
end
local fn,err=loadstring(table.concat(o),"=ENRIQUE")
if fn then fn()else warn("[ENRIQUE] "..tostring(err))end
