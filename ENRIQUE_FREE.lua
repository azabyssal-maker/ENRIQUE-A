-- ENRIQUE FREE V55 Encrypted
local key="hJEz4vHLcPD/4CETrGPTaPsGLnE6RP1lpbmGiXv5daU="
local sig="ENRIQ"
local function b64d(s)
local a="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
s=s:gsub("[^"..a.."]","")
local r={}local n=0 local b={}
for i=1,#s do local c=s:sub(i,i)
if c=="="then break end n=n*64+(a:find(c)-1)
if i%4==0 or i==#s then for j=2,0,-1 do b[#b+1]=n/(2^(j*8))%256 end n=0 end end
return string.char(table.unpack(b))
end
local sd=game:HttpGet("https://raw.githubusercontent.com/azabyssal-maker/ENRIQUE-A/main/ENRIQUE_DATA.txt",true)
local k=b64d(key)
local o={}
for i=1,#sd do
o[i]=string.char(string.byte(sd,i)~string.byte(k,((i-1)%#k)+1))
end
local raw=table.concat(o)
local r={}
for i=1,#raw do local b=string.byte(raw,i)
r[i]=string.char(i<=5 and b~string.byte(sig,i) or b)
end
local fn,err=loadstring(table.concat(r),"=ENRIQUE")
if fn then fn()else warn("[ENRIQUE] "..tostring(err))end
