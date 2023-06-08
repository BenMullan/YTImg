This directory should be served as www.gstatic.com.

┌───────────────────┐ 
│       YTImg C     │▒
└───────────────────┘▒
 ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
 
Setup Instructions (Client-side Version):
-----------------------------------------
	1. Install IIS: Run `OptionalFeatures.exe`, and (if you don't really know what you're doing) just tick all components under "Internet Information Services" and click [OK].
	2. Copy the contents of `ClientSideVersion\` (cv, eureka, ...) to C:\inetpub\wwwroot\ . Delete anything that was already in there.
	3. Run `INetMgr.exe`, and click [Start] for the "Default Web Site". (Ensure https is enabled for this site; select or generate an SSL certificate to use).
	You should now be able to visit https://localhost/cv/js/sender/v1/cast_sender.js and see the YTImg comment at the top.
	4. Open the file C:\Windows\System32\drivers\etc\hosts in notepad, and add a new line at the bottom saying `127.0.0.1	www.gstatic.com`.
	5. Go to https://www.gstatic.com/ in your browser, and get past the SSL cert warning. In chrome, literally type `thisisunsafe` directly onto the error page. You should now be able to visit https://www.youtube.com/ and see the modified Thumbnails.

How it works (Client-side Version):
-----------------------------------
	1. YouTube successfully loads thumbnails from `//i.ytimg.com`.
	2. The client is configured with a DNS record to point `www.gstatic.com` to `127.0.0.1`, which hosts the `ClientSideVersion\` directory, wherein the script `\cv\js\sender\v1\cast_sender.js` has been modified.  
	3. Every few seconds, this script applies the configured effect to all visible thumbnails on the YouTube page. You can choose which effect is used by setting it at the top of the `cast_sender.js` file.

Ben Mullan (c) 2023 (github.com/BenMullan)