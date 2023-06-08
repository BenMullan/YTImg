This directory should be served as i.ytimg.com.

┌───────────────────┐ 
│       YTImg S     │▒
└───────────────────┘▒
 ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒

YTImg replaces YouTube Thumbnails with either
	1) A static image; the "Default.JPG" file, or...
	2) A real-time image captured from the Webcam.

Setup Instrucitons:
-------------------
	1) Install IIS: Run OptionalFeatures.exe, and (if you don't really know what you're doing) just tick all components under "Internet Information Services" and click [OK].
	2) Install the IIS URL-Rewrite-Module from https://www.iis.net/downloads/microsoft/url-rewrite
	3) Copy all the YTImg files (Web.config, CamCapture.ASPX, etc...) to C:\inetpub\wwwroot\ . Delete anything that was already in there.
	4) Run INetMgr.exe, and click [Start] for the "Default Web Site". (Ensure https is enabled for this site; select or generate an SSL certificate to use).
		You should now be able to visit https://localhost/Whatever and Default.JPG should be served, no matter the URL.
	5) Open the file C:\Windows\System32\drivers\etc\hosts in notepad, and add a new line at the bottom saying "127.0.0.1	i.ytimg.com".
	6) Go to https://i.ytimg.com/ in your browser, and get past the SSL cert warning. In chrome, literally type "thisisunsafe" directly onto the error page.
		You should now be able to visit https://www.youtube.com/ and see the replaced Thumbnails.

Enabling Static or Webcam Mode:
-------------------------------
	- The static image mode is enabled by default, so whatever the "Default.JPG" file is, will appear for every Thumbnail.
	- To enable the Webcam Mode, open the Web.config file in notepad, and find the line that says...
			<action type="Rewrite" url="Default.JPG" appendQueryString="false" />
		To enable Webcam mode, make the url equal to "CamCapture.ASPX" instead of "Default.JPG".
		You can change it back to Default.JPG at any time.

Misc.:
------
	For the Webcam image, the file is cached as "WebcamCaptureCache.JPG".
	When a request comes in, the logic within "CamCapture.ASPX" checks to see if [the Webcam cache exists] and [whether it's less than a minute old].
	If it is, then the cache is served. Otherwise, a new image is captured from the Webcam, and is saved in the cache file.

	Even if YouTube is visited on a different browser, user-account, or session, the thumbnails will still be served from the bogus server instead of the real //i.ytimg.com.

How it works (Server-side Version):
-----------------------------------
	1. YouTube attempts to load in a thumbnail image from `//i.ytimg.com` in the format `https://i.ytimg.com/vi/<VIDEO_ID>/hq720.jpg`
	2. The client this request is being made from, sends the request to a YTImg server instance (e.g. running on `127.0.0.1`), instead of the real `i.ytimg.com` server. This is done either by inserting the line `127.0.0.1	i.ytimg.com` into the `\Windows\System32\drivers\etc\hosts` file, or by setting the client to use a DNS server which reports a similarly bogus IP-Address.
	3. The request lands on a YTImg server, which - depending on the mode configured - will either serve `Default.JPG`, or will take an ad-hoc image from the webcam, save it as `WebcamCaptureCache.JPG`, and serve that. If the webcam cache JPG exists and is less than 1 minute old, it will be served without taking a new image.
	4. The client receives the custom thumbnail, and renders it into the YouTube Webpage.

Ben Mullan (c) 2023 (github.com/BenMullan)