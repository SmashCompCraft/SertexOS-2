--SertexOS 2 Installer

shell.setDir("/")
fs.makeDir("/.SertexOS/autorun")

if not fs.exists("/.SertexOS/config") then
	local f = fs.open("/.SertexOS/config","w")
	f.write("configVersion = 1\nlanguage = \"en\"")
	f.close()
else
	dofile("/.SertexOS/config")
	if not configVersion == 1 then
		local f = fs.open("/.SertexOS/config","w")
		f.write("configVersion = 1\nlanguage = \"en\"")
		f.close()
	end
end

systemDir = ".SertexOS"

local files = {
	["src/SertexOS.lua"] = "/.SertexOS/SertexOS",
	["src/apps/shell/shell.lua"] = "/.SertexOS/apps/shell/app",
	["src/apps/shell/logo"] = "/.SertexOS/apps/shell/logo",
	["src/apps/firewolf/firewolf.lua"] = "/.SertexOS/apps/firewolf/app",
	["src/apps/firewolf/logo"] = "/.SertexOS/apps/firewolf/logo",
	["src/apps/sertexexplore/se.lua"] = "/.SertexOS/apps/sertexexplore/app",
	["src/apps/sertexexplore/logo"] = "/.SertexOS/apps/sertexexplore/logo",
	["src/apis/api.lua"] = "/.SertexOS/apis/api",
	["src/apis/ui.lua"] = "/.SertexOS/apis/ui",
	["src/apis/graphics.lua"] = "/.SertexOS/apis/graphics",
	["src/apis/sertextext.lua"] = "/.SertexOS/apis/sertextext",
	["src/apis/sha256.lua"] = "/.SertexOS/apis/sha256",
	["update"] = "/.SertexOS/update",
	["src/startup"] = "/startup",
	["src/lang/en.lang"] = "/.SertexOS/lang/en.lang",
	["src/lang/it.lang"] = "/.SertexOS/lang/it.lang",
	["src/lang/de.lang"] = "/.SertexOS/lang/de.lang",
}

local githubUser    = "Sertex-Team"
local githubRepo    = "SertexOS-2"
local githubBranch  = "master"

local installerName = "SertexOS 2 Updater" -- if you need one, this will replace "Installer for user/repo, branch branch"

local function clear()
	term.clear()
	term.setCursorPos(1, 1)
end

local function httpGet(url, save)

	if not url then
		error("not enough arguments, expected 1 or 2", 2)
	end
	local remote = http.get(url)
	if not remote then
		return false
	end
	local text = remote.readAll()
	remote.close()
	if save then
		local file = fs.open(save, "w")
		file.write(text)
		file.close()
		return true
	end
	return text
end

local function get(user, repo, bran, path, save)
	if not user or not repo or not bran or not path then
		error("not enough arguments, expected 4 or 5", 2)
	end
    local url = "https://raw.github.com/"..user.."/"..repo.."/"..bran.."/"..path
	local remote = http.get(url)
	if not remote then
		return false
	end
	local text = remote.readAll()
	remote.close()
	if save then
		if text then
			local file = fs.open(save, "w")
			file.write(text) --# attempt to index ? a nil value
			file.close()
			return true
		else
			return false
		end
	end
	return text
end

local function getFile(file, target)
	return get(githubUser, githubRepo, githubBranch, file, target)
end

shell.setDir("")

clear()

print(installerName or ("Installer for " .. githubUser .. "/" .. githubRepo .. ", branch " .. githubBranch))
print("Getting files...")
local fileCount = 0
for _ in pairs(files) do
	fileCount = fileCount + 1
end
local filesDownloaded = 0

local w, h = term.getSize()

for k, v in pairs(files) do
	term.setTextColor(colors.red)
	term.setBackgroundColor(colors.white)
	clear()
	term.setCursorPos(2, 2)
	print(installerName or ("Installer for " .. githubUser .. "/" .. githubRepo .. ", branch " .. githubBranch))
	term.setCursorPos(2, 4)
	print("File: "..v)
	term.setCursorPos(2, h - 1)
	print(tostring(math.floor(filesDownloaded / fileCount * 100)).."% - "..tostring(filesDownloaded + 1).."/"..tostring(fileCount))
	local ok = k:sub(1, 4) == "ext:" and httpGet(k:sub(5), v) or getFile(k, v)
	if not ok then
		if term.isColor() then
			term.setTextColor(colors.red)
		end
		term.setCursorPos(2, 6)
		print("Error getting file:")
		term.setCursorPos(2, 7)
		print(k)
		sleep(1)
	end
	filesDownloaded = filesDownloaded + 1
end
clear()
term.setCursorPos(2, 2)
print("Press any key to continue.")
local w, h = term.getSize()
term.setCursorPos(2, h-1)
print("100% - "..tostring(filesDownloaded).."/"..tostring(fileCount))
os.pullEvent("key")

os.reboot()

