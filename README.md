<H1>文件切割器</H1>

<H3>简介</H3>

> 这是一个大型文件切割组装器，就是将一个大型文件分割成若干个小型切片文件，没有进行CRC校验；也可以将若干个已切割的切片文件（完整的）组装成一个完整文件。	
	
<H3>有什么卵用？</H3>
	适用于将 Github当做文件服务器的人
>因为Github对文件大小有限制。当用户准备将一个大于50Mb的文件上传至Github时，将会接收到警告；当用户准备将一个大于100MB的文件上传至Github时，将会得到一个错误提示。



<image src="png/01.png" width=150>
<image src="png/02.png" width=150>
<image src="png/03.png" height=150>

	1、可以点击按钮手动添加文件
	2、可以通过拖拽你添加文件
	3、通过偏好设置设置切片大小