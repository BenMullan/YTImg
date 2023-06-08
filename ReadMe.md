# YTImg
Intercepts YouTube's thumbnail-loading requests, and replaces the real thumbnails with either...
- [ServerSide] A static image of your choosing,
- [ServerSide] A real-time image captured from the Webcam, or
- [ClientSide] Modified versions of the actual thumbnails, with rotation, saturation, or shift effects applied.

<br/><img src="https://github.com/BenMullan/YTImg/blob/master/_Resources/StaticImage_Demo.png?raw=true" height="80%" width="80%" /><br/>

### Setup Instructions (Server-side Version)
1. Install IIS: Run `OptionalFeatures.exe`, and (if you don't really know what you're doing) just tick all components under "Internet Information Services" and click [OK].
2. Install the IIS URL-Rewrite-Module from https://www.iis.net/downloads/microsoft/url-rewrite
3. Copy the contents of `ServerSideVersion\` (Web.config, CamCapture.ASPX, ...) to C:\inetpub\wwwroot\ . Delete anything that was already in there.
4. Run `INetMgr.exe`, and click [Start] for the "Default Web Site". (Ensure https is enabled for this site; select or generate an SSL certificate to use).
You should now be able to visit https://localhost/Whatever and Default.JPG should be served, no matter the URL.
5. Open the file C:\Windows\System32\drivers\etc\hosts in notepad, and add a new line at the bottom saying `127.0.0.1	i.ytimg.com`.
6. Go to https://i.ytimg.com/ in your browser, and get past the SSL cert warning. In chrome, literally type `thisisunsafe` directly onto the error page. You should now be able to visit https://www.youtube.com/ and see the replaced Thumbnails.

### Enabling Static or Webcam Mode (Server-side Version)
- The static image mode is enabled by default, so whatever the `Default.JPG` file is, will appear for every Thumbnail.
- To enable the Webcam Mode, open the `Web.config` file in notepad, and find the line that says...
`<action type="Rewrite" url="Default.JPG" appendQueryString="false" />`
To enable Webcam mode, make the url equal to "CamCapture.ASPX" instead of "Default.JPG". You can change it back to Default.JPG at any time.

### Misc. (Server-side Version)
- For the Webcam image, the file is cached as "WebcamCaptureCache.JPG".
When a request comes in, the logic within "CamCapture.ASPX" checks to see if [the Webcam cache exists] and [whether it's less than a minute old]. If it is, then the cache is served. Otherwise, a new image is captured from the Webcam, and is saved in the cache file.
- Even if YouTube is visited on a different browser, user-account, or session, the thumbnails will still be served from the bogus server instead of the real //i.ytimg.com.

### How it works (Server-side Version)
1. YouTube attempts to load in a thumbnail image from `//i.ytimg.com` in the format `https://i.ytimg.com/vi/<VIDEO_ID>/hq720.jpg`
2. The client this request is being made from, sends the request to a YTImg server instance (e.g. running on `127.0.0.1`), instead of the real `i.ytimg.com` server. This is done either by inserting the line `127.0.0.1	i.ytimg.com` into the `\Windows\System32\drivers\etc\hosts` file, or by setting the client to use a DNS server which reports a similarly bogus IP-Address.
3. The request lands on a YTImg server, which - depending on the mode configured - will either serve `Default.JPG`, or will take an ad-hoc image from the webcam, save it as `WebcamCaptureCache.JPG`, and serve that. If the webcam cache JPG exists and is less than 1 minute old, it will be served without taking a new image.
4. The client receives the custom thumbnail, and renders it into the YouTube Webpage.

### Setup Instructions (Client-side Version)
1. Install IIS: Run `OptionalFeatures.exe`, and (if you don't really know what you're doing) just tick all components under "Internet Information Services" and click [OK].
2. Copy the contents of `ClientSideVersion\` (cv, eureka, ...) to C:\inetpub\wwwroot\ . Delete anything that was already in there.
3. Run `INetMgr.exe`, and click [Start] for the "Default Web Site". (Ensure https is enabled for this site; select or generate an SSL certificate to use).
You should now be able to visit https://localhost/cv/js/sender/v1/cast_sender.js and see the YTImg comment at the top.
4. Open the file C:\Windows\System32\drivers\etc\hosts in notepad, and add a new line at the bottom saying `127.0.0.1	www.gstatic.com`.
5. Go to https://www.gstatic.com/ in your browser, and get past the SSL cert warning. In chrome, literally type `thisisunsafe` directly onto the error page. You should now be able to visit https://www.youtube.com/ and see the modified Thumbnails.

### How it works (Client-side Version)
1. YouTube successfully loads thumbnails from `//i.ytimg.com`.
2. The client is configured with a DNS record to point `www.gstatic.com` to `127.0.0.1`, which hosts the `ClientSideVersion\` directory, wherein the script `\cv\js\sender\v1\cast_sender.js` has been modified.  
3. Every few seconds, this script applies the configured effect to all visible thumbnails on the YouTube page. You can choose which effect is used by setting it at the top of the `cast_sender.js` file.

*Ben Mullan (c) 2023 (github.com/BenMullan)*