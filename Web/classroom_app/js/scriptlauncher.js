

if (BrowserDetect.browser != 'Explorer')
{
  // console.log("trying");
	<!--<![CDATA[
document.write("<scr"+"ipt language='javascript' type='text/javascript' src='js/spectrum/spectrum.js'></scr" + "ipt>");
document.write("<scr"+"ipt language='javascript' type='text/javascript' src='js/kinetic-v4.5.2.min.js'></scr" + "ipt>");
document.write("<scr"+"ipt language='javascript' type='text/javascript' src='js/jquery-ui-1.10.0.custom/js/jquery-ui-1.10.0.custom.js'></scr" + "ipt>");
document.write("<scr"+"ipt language='javascript' type='text/javascript' src='js/classroom.js'></scr" + "ipt>");
document.write("<scr"+"ipt language='javascript' type='text/javascript' src='js/Blob.js'></scr" + "ipt>");
document.write("<scr"+"ipt language='javascript' type='text/javascript' src='js/canvas-toBlob.js'></scr" + "ipt>");
document.write("<scr"+"ipt language='javascript' type='text/javascript' src='js/FileSaver.js'></scr" + "ipt>");
document.write("<scr"+"ipt language='javascript' type='text/javascript' src='js/jquery.ui.touch-punch.min.js'></scr" + "ipt>");//]]>-->

$(document).ready(function() {
	$('#dialogs').css('visibility','inherit');
	$('#instructions').css('visibility','inherit');
	$('#header').text('Designing Your Classroom');

});
}
else
{
	$(document).ready(function(){
	
	$("#nav_container").hide();
	$('#header').text('Designing Your Classroom');
	
	$('#instructions').css('visibility','inherit').html('<p>Oops!  This applet will not run in Internet Explorer.</p><p>Try running it on one of the following platforms: </p><ul class="browsers"><li>Firefox 4.0 and up</li><li>Safari 4.0 and up</li><li>Chrome 14.0 and up</li><li>Opera 10.0 and up</li><li>iOS</li><li>Samsung Galaxy Note 4.0</li><li>Amazon Kindle Fire</li></ul>');
	});
	
}

