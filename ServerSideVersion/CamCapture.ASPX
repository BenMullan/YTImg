<!--
	YTImg CamCapture Server Page
	Captures and Serves an image from the specified camera; 0 is the 1st Video Device on the system, 1 the 2nd, etc...

	Ben Mullan (c) 2023
-->

<%@ Page Language="VB" Debug="true" AutoEventWireup="false" %>
<%
	
	Const _WebcamCaptureCache_FileName$ = "WebcamCaptureCache.JPG"
	Dim _WebcamDeviceToUse_Index As [Byte] = 0
	Dim _CacheInvalidationPeriod As New TimeSpan(hours:=0, minutes:=1, seconds:=0) 'After this length of time, a new Webcam Image is captured and cached

	REM Captures a Webcam-Image, without ever saving it to disk
	Dim _CaptureWebcamImage As Func(Of [Byte], Drawing.Bitmap) = _
		Function(_WebcamDeviceNumber As [Byte]) As Drawing.Bitmap

			Dim _WebcamCollection As New Global.AForge.Video.DirectShow.FilterInfoCollection(AForge.Video.DirectShow.FilterCategory.VideoInputDevice)
			Dim _WebcamDevice As New Global.AForge.Video.DirectShow.VideoCaptureDevice(_WebcamCollection.Item(_WebcamDeviceNumber).MonikerString)
			Dim _CapturedBitmap As Global.System.Drawing.Bitmap = Nothing

			AddHandler _WebcamDevice.NewFrame, _
				Sub(_Sender As [Object], _NewFrameEventArgs As AForge.Video.NewFrameEventArgs)
					_CapturedBitmap = New Drawing.Bitmap(_NewFrameEventArgs.Frame)
					_WebcamDevice.SignalToStop()
				End Sub

			_WebcamDevice.Start()

			'Wait for the other thread to put the BMP-Data into the _CapturedBitmap Object
			While _CapturedBitmap Is Nothing : Threading.Thread.Sleep(50) : End While : Threading.Thread.Sleep(10)
			Return _CapturedBitmap

		End Function
	
	'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
	'''' End of declarations/definitions; start of executable logic
	'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
	
	Try

		Response.Clear() : Response.ContentType = "image/jpeg" : Response.StatusCode = System.Net.HttpStatusCode.OK

		REM If WebcamCaptureCache.JPG exists, AND it's less than a minute old, then serve it.
		REM Otherwise, capture a Webcam Image, and cache it for subsequent requests within the next minute.

		Dim _WebcamCaptureCacheFile As New IO.FileInfo(IO.Path.Combine(HttpContext.Current.Server.MapPath("~"), _WebcamCaptureCache_FileName))

		If Not (_WebcamCaptureCacheFile.Exists AndAlso (DateTime.Now - _WebcamCaptureCacheFile.LastWriteTime) < _CacheInvalidationPeriod) _
		 Then _CaptureWebcamImage.Invoke(_WebcamDeviceToUse_Index).Save(_WebcamCaptureCacheFile.FullName, Drawing.Imaging.ImageFormat.Jpeg)

		REM Now that the Webcam Cache exists - and is less than a minute old - serve it...
		Response.WriteFile(_WebcamCaptureCacheFile.FullName)

	Catch _Ex As Exception : Response.Clear() : Response.ContentType = "text/plain" : Response.StatusCode = System.Net.HttpStatusCode.InternalServerError : Response.Write("Internal Server Error: " & _Ex.Message) : End Try
	
%>