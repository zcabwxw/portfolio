/****************************************************************************
 *							Classroom.js
 *							Nevin Katz
 *							EdTech Leaders Online
 *							Classroom Map Editor
 *
 ***************************************************************************/
$(document).ready(function () {

    // for tool hint timeouts
    var timer1, resizeImage;
	
	// number of customImages from other sites added by user
	var customImages = 0;

    // stage 
    var stage = new Kinetic.Stage({
        container: "container",
        width: 840,
        height: 700,
        stroke: 'blue',
        strokeWidth: 4

    });

    // coordinates for upper left-hand corner of classroom floor
    var leftEdge = 110;
    var topEdge = 74;

    // grid lines
    var horizLines = 20;
    var vertLines = 20;

    // grid intervals
    var horizInterval = 64;
    var vertInterval = 64;

    // starting wall fills: 4 walls, floor, font box background, font color
    var startingFills = ['#9ab7d3', '#dae7ef', '#cee1ed', '#a9c3de', '#e8c781', '#f2f2f2', '#555'];

    var textBgColor = startingFills[5];
    var fontColor = startingFills[6];

    // touch coordinates; used for rotation
    var x1, x2, y1, y2;
    var currentPos;

    // stores the objects that are on the art layer
    var objectArray = [];

    var shapeArray = [];

    // an object that has its rotation enabled is the currentTarget
    var currentTarget = null;

    // keeps track of the objects that have been added
    var objectCounter = 0;


    var moveCounter = 0;

    //  boardLayer has the classroom, walls, and grid
    var boardLayer = new Kinetic.Layer();

    // classroom and walls are in this group
    var boardGroup = new Kinetic.Group();

    var gridGroup = new Kinetic.Group();


    // paletteLayer has the palette with the classroom items
    var paletteLayer = new Kinetic.Layer();

    var messageLayer = new Kinetic.Layer();
    // this is the layer where the notes end up after the first drag. 
    var artLayer = new Kinetic.Layer();

    var textLayer = new Kinetic.Layer();

    var toolButtonLayer = new Kinetic.Layer();

    /*
     * the artLayer consists of groups, placed one on top of the other.
     */

    // this is the bottom layer. 
    var artGroup0 = new Kinetic.Group({
        id: "0"
    });
    var artGroup1 = new Kinetic.Group({
        id: "1"
    });
    var artGroup2 = new Kinetic.Group({
        id: "2"
    });
    var artGroup3 = new Kinetic.Group({
        id: "3"
    });

    var itemGroup = new Kinetic.Group();

    var navGroup = new Kinetic.Group();

    // palette groups

    var itemTypeCounter = 0;

    var techGroup = new Kinetic.Group({
        id: "techgroup",
        scrollable: true
    });

    var winGroup = new Kinetic.Group({
        id: "wingroup"
    });

    var wallGroup = new Kinetic.Group({
        id: "wallgroup"
    });

    var furnGroup = new Kinetic.Group({
        id: "furngroup"
    });

    /* tool tip code*/
    var tooltipLayer = new Kinetic.Layer({

    });

    var tooltip = new Kinetic.Group({
        visible: false

    });

    var tooltiptext = new Kinetic.Text({
        text: "test",
        fontFamily: "Calibri",
        fontSize: 14,
        padding: 5,
        fill: "white",
        opacity: 0.75,


    });

    var tooltiprect = new Kinetic.Rect({
        opacity: .75,
        fill: 'black',
        height: tooltiptext.getHeight(),
        width: 200

    })

    tooltiptext.setOffset({
        y: 0
    })

    tooltip.add(tooltiprect);

    tooltip.add(tooltiptext);

    /* tool tip array */

    var tips = ['Add Shape', 'Add Image', 'Add Text', 'Erase Object', 'Rotate Object', 'Resize Object'];

    // get the dimensions of the stage in easy-to-write global variables
    var sHeight = stage.getHeight();
    var sWidth = stage.getWidth();

    var toolMode = 'object';

    // groups the toolbar with its buttons
    var toolbarGroup = new Kinetic.Group();

    // declare image object - this can probably go.
    var board = new Image();

    // declare group
    var notesGroup = new Kinetic.Group({
        draggable: true
    });



    // declare note types - these will become classroom objects
    var notes = ['yellow', 'blue', 'green', 'pink'];

    //this variable is used to position the note and helps set file name
    var counter = 0;

    // used to build toolbar
    var toolCounter = 0;

    // used to build item palette
    var itemCounter = 0;

    // declare the rect that will be used as a palette = though we'd like to call this by name. 
    var rect;


    var addingNote = false;

    // animation frames for itemPanel buttons

    var winFrames = {

        objectUp: [{
            x: 10,
            y: 127,
            width: 80,
            height: 25
        }],

        objectDown: [{
            x: 97,
            y: 127,
            width: 80,
            height: 25

        }]

    };

    var furnFrames = {

        objectUp: [{
            x: 10,
            y: 89,
            width: 80,
            height: 25
        }],

        objectDown: [{
            x: 97,
            y: 89,
            width: 80,
            height: 25

        }]
    };

    var wallFrames = {

        objectUp: [{
            x: 10,
            y: 52,
            width: 80,
            height: 25
        }],

        objectDown: [{
            x: 97,
            y: 52,
            width: 80,
            height: 25

        }]

    };

    var techFrames = {

        objectUp: [{
            x: 10,
            y: 15,
            width: 80,
            height: 25
        }],

        objectDown: [{
            x: 97,
            y: 10,
            width: 80,
            height: 25

        }]


    };

    /*
     * animation frames for the toolbar buttons
     */
    var shapeFrames = {

        objectUp: [{
            x: 9,
            y: 8,
            width: 49,
            height: 49
        }],

        objectDown: [{
            x: 68,
            y: 8,
            width: 49,
            height: 49
        }]
    }

    var eraserFrames = {

        objectUp: [{
            x: 9,
            y: 68,
            width: 49,
            height: 49
        }],

        objectDown: [{
            x: 68,
            y: 68,
            width: 49,
            height: 49
        }]
    }

    var textFrames = {

        objectUp: [{
            x: 9,
            y: 127,
            width: 49,
            height: 49
        }],

        objectDown: [{
            x: 68,
            y: 127,
            width: 49,
            height: 49
        }]
    }

    var rotateFrames = {

        objectUp: [{
            x: 9,
            y: 186,
            width: 49,
            height: 49
        }],

        objectDown: [{
            x: 68,
            y: 186,
            width: 49,
            height: 49
        }]
    }

    var cameraFrames = {

        objectUp: [{
            x: 9,
            y: 245,
            width: 49,
            height: 49
        }],

        objectDown: [{
            x: 68,
            y: 245,
            width: 49,
            height: 49
        }]
    }

    var imageFrames = {

        objectUp: [{
            x: 9,
            y: 306,
            width: 49,
            height: 49
        }],

        objectDown: [{
            x: 68,
            y: 306,
            width: 49,
            height: 49
        }]
    }

    var resizeFrames = {

        objectUp: [{
            x: 9,
            y: 367,
            width: 49,
            height: 49
        }],

        objectDown: [{
            x: 68,
            y: 367,
            width: 49,
            height: 49
        }]
    }

    // arrays that hold the names of button sprites

    var toolbarButtons = [shapeFrames, imageFrames, textFrames, eraserFrames, rotateFrames, resizeFrames];

    var toolNames = ['Add Shape', 'Add Image', 'Add Text', 'Erase', 'Rotate', 'Resize'];

    var itemButtons = [techFrames, furnFrames, winFrames];


    /*
     * End of variables; start functions 
     */
    /*
     * spectrum code
     */

    function setColorPickers() {
        for (var i = 0; i < 9; i++) {
            var myID = "#color" + i;
            colorPicker(myID, i);
        }

    }



    /*
     * JQuery Button Listeners
     */

    $('#clear').click(function () {
        $('#alert_box').dialog("open");


    });

    $('#togglewalls').click(function () {
        var myWalls = stage.get('.myWall');


        if (myWalls[0].attrs.visible) {
            for (i = 0; i < 4; i++)
            myWalls[i].hide();
            boardLayer.draw();
            $('#togglewalls').text("Show Walls");
        } else {
            for (j = 0; j < 4; j++)
            myWalls[j].show();
            boardLayer.draw();
            $('#togglewalls').text("Hide Walls");

        }
    });
    $('#togglegrid').click(function () {
        if (!gridGroup.getVisible()) {
            gridGroup.show();
            $('#togglegrid').text("Hide Grid");
        } else {
            gridGroup.hide();
            $('#togglegrid').text("Show Grid");
        }

        boardLayer.draw();

    });


    // help button at top-right of screen
    $('#help').click(function () {
        $('#help_box').dialog("open");
    });


    // color picker widget
    function colorPicker(myID, i) {

        $(myID).spectrum({
            color: startingFills[i],
            showInput: true,
            className: "full-spectrum",
            showInitial: true,
            showPalette: true,
            showSelectionPalette: true,
            maxPaletteSize: 10,
            preferredFormat: "hex",
            localStorageKey: "spectrum.demo",
            move: function (color) {

            },
            show: function (color) {

            },
            beforeShow: function (color) {

            },
            hide: function (color) {


            },
            change: function (color) {


                setColor(color.toHexString(), this.id);


            },
            palette: [
                ["rgb(0, 0, 0)",
                    "rgb(67, 67, 67)",
                    "rgb(102, 102, 102)",
                    "rgb(204, 204, 204)",
                    "rgb(217, 217, 217)",
                    "rgb(255, 255, 255)"],
                ["rgb(152, 0, 0)",
                    "rgb(255, 0, 0)",
                    "rgb(255, 153, 0)",
                    "rgb(255, 255, 0)",
                    "rgb(0, 255, 0)",
                    "rgb(0, 255, 255)",
                    "rgb(74, 134, 232)",
                    "rgb(0, 0, 255)",
                    "rgb(153, 0, 255)",
                    "rgb(255, 0, 255)"],
                ["rgb(230, 184, 175)",
                    "rgb(244, 204, 204)",
                    "rgb(252, 229, 205)",
                    "rgb(255, 242, 204)",
                    "rgb(217, 234, 211)",
                    "rgb(208, 224, 227)",
                    "rgb(201, 218, 248)",
                    "rgb(207, 226, 243)",
                    "rgb(217, 210, 233)",
                    "rgb(234, 209, 220)",
                    "rgb(221, 126, 107)",
                    "rgb(234, 153, 153)",
                    "rgb(249, 203, 156)",
                    "rgb(255, 229, 153)",
                    "rgb(182, 215, 168)",
                    "rgb(162, 196, 201)",
                    "rgb(164, 194, 244)",
                    "rgb(159, 197, 232)",
                    "rgb(180, 167, 214)",
                    "rgb(213, 166, 189)",
                    "rgb(204, 65, 37)",
                    "rgb(224, 102, 102)",
                    "rgb(246, 178, 107)",
                    "rgb(255, 217, 102)",
                    "rgb(147, 196, 125)",
                    "rgb(118, 165, 175)",
                    "rgb(109, 158, 235)",
                    "rgb(111, 168, 220)",
                    "rgb(142, 124, 195)",
                    "rgb(194, 123, 160)",
                    "rgb(166, 28, 0)",
                    "rgb(204, 0, 0)",
                    "rgb(230, 145, 56)",
                    "rgb(241, 194, 50)",
                    "rgb(106, 168, 79)",
                    "rgb(69, 129, 142)",
                    "rgb(60, 120, 216)",
                    "rgb(61, 133, 198)",
                    "rgb(103, 78, 167)",
                    "rgb(166, 77, 121)",
                    "rgb(91, 15, 0)",
                    "rgb(102, 0, 0)",
                    "rgb(120, 63, 4)",
                    "rgb(127, 96, 0)",
                    "rgb(39, 78, 19)",
                    "rgb(12, 52, 61)",
                    "rgb(28, 69, 135)",
                    "rgb(7, 55, 99)",
                    "rgb(32, 18, 77)",
                    "rgb(76, 17, 48)"]
            ]
        });
    }

    // change width and height of classroom...within reason!
    function setDimensions(nWidth, nHeight) {

        // get the floor object
        var myFloor = stage.get('#wall4')[0];

        // if there is a change in width, resize the grid horizontally. 
        if (nWidth != myFloor.attrs.width) resizeGridHoriz(nWidth, nHeight);

        // if there is a change in height, resize the grid vertically. 
        if (nHeight != myFloor.attrs.height) resizeGridVert(nWidth, nHeight);

        // resize the floor
        myFloor.setAttrs({
            height: nHeight,
            width: nWidth,
            duration: 0.01
        });

        //update the board layer (that contains the floor)
        boardLayer.draw();

        // change the dimensions of the four walls
        changeWalls(nWidth, nHeight);
    }

    function calcWallPoints(myWidth, myHeight) {
        var wallVert = 65;
        var wallHoriz = 55;

        // floor corners
        var floorT = topEdge + wallVert;
        var floorR = leftEdge + myWidth - wallHoriz;
        var floorL = leftEdge + wallHoriz;
        var floorB = topEdge + myHeight - wallVert;

        var rightEdge = leftEdge + myWidth;
        var botEdge = topEdge + myHeight;

        /// point arrays
        var points = [];

        // top wall points
        points[0] = [leftEdge, topEdge, rightEdge, topEdge, floorR, floorT, floorL, floorT];

        // right wall points
        points[1] = [rightEdge, topEdge, rightEdge, botEdge, floorR, floorB, floorR, floorT];

        // bottom wall points
        points[2] = [rightEdge, botEdge, leftEdge, botEdge, floorL, floorB, floorR, floorB];

        // left wall points
        points[3] = [leftEdge, topEdge, floorL, floorT, floorL, floorB, leftEdge, botEdge];

        return points;
    }

    function changeWalls(myWidth, myHeight) {
        var allPoints = calcWallPoints(myWidth, myHeight);
        for (var e = 0; e < 4; e++) {
            var thisWall = stage.get('#wall' + e)[0];

            thisWall.setPoints(allPoints[e])

            boardLayer.draw();
        }
    }

    // sets thset color of floor & walls based on input
    function setColor(newColor, id) {
        switch (id) {
            case "color6":
                fontColor = newColor;
                break;

            case "color5":
                textBgColor = newColor;
                break;

            case "color4":
            case "color3":
            case "color2":
            case "color1":
            case "color0":
                var myName = '#wall' + id.substring(id.length - 1, id.length);
                var mySurface = stage.get(myName)[0];
                mySurface.setFill(newColor);
                boardLayer.draw();
                break;
        }

    }
    /*
     * text background settings
     */

    noTextBg();

    // code for loading JSON data
    $('#bg').change(function () {
        toggleTextBg(this);
    });

    // function for background checkbox in text dialog
    function toggleTextBg(cb) {
        cb.checked == false ? noTextBg() : textBg();
    }

    // shows / hides bg color picker depending on whether text background is checked
    function noTextBg() {
        $("#bgc").hide();
        textbg = false;

    }

    function textBg() {
        $("#bgc").show();
        textbg = true;
    }

    /*
     * helper function for creating line breaks with \n in jquery
     */
    function newLines(text) {
        var htmls = [];
        var lines = text.split(/\n/);
        // The temporary <div/> is to perform HTML entity encoding reliably.
        //
        // document.createElement() is *much* faster than jQuery('<div/>')
        // http://stackoverflow.com/questions/268490/
        //
        // You don't need jQuery but then you need to struggle with browser
        // differences in innerText/textContent yourself
        var tmpDiv = $(document.createElement('div'));
        for (var i = 0; i < lines.length; i++) {
            htmls.push(tmpDiv.text(lines[i]).html());
        }
        return htmls.join("<br>");
    }

    // whether textbg = false
    var textbg = false;

    // mouse variable
    var isDown = false;

    $(document).mousedown(function () {
        isDown = true;
    });

    $(document).mouseup(function () {
        if (isDown) isDown = false;
    });

    // setting up alert box for the clear all functionality
    $("#alert_box").dialog({

        autoOpen: false,
        width: 400,
        listening: false,
        resizable: false,
        modal: true,
        show: 'fade',
        hide: 'fade',
        draggable: true,
        buttons: [{
            text: "Proceed",
            click: function () {
                $(this).dialog("close");
                clearMap();
            }
        }, {
            text: "Cancel",
            click: function () {
                $(this).dialog("close");
            }
        }]
    });

    // this button opens the dimension dialog. 
    $("#dimensions").click(function () {
        $("#dimensions_dialog").dialog("open");

        var myFloor = stage.get('#wall4')[0];

        var myHeight = String(myFloor.attrs.height);
        var myWidth = String(myFloor.attrs.width);

        $('#roomWidth').val(myWidth);
        $('#roomHeight').val(myHeight);

        $('#error').text('');

    });

    $(".sidelength").spinner({
        min: 20,
        max: 200
    });
    $("#num_sides").spinner({
        min: 3,
        max: 12
    });



    $("#capture").click(function () {
        captureImage();
    });
    $("#help").click(function () {

        $("#help_box").dialog("open");
        $('#help_box', window.parent.document).scrollTop(0);
    });

    // this button opens the color picker dialog. 
    $("#colors").click(function () {


        $("#color_box").dialog("open");
        $("#color_box").dialog("option", "position", "center");
    });

    // radio buttons
    $('.pre').click(function () {

        var presetText = $(this).val()

        //$('#enter_text').val('');
        $('#enter_text').val(presetText);
        $('#enter_text').text(presetText);

    });

    function showPolygonOptions() {
        $('#polygon').show();
        $('#round').hide();
        $('#rectangle').hide();
    }

    $('.shape_type').click(function () {

        switch ($(this).val()) {
            case "rPolygon":
            case "iPolygon":
                showPolygonOptions();
                break;

            case "Rectangle":
                // //// // // // // console.log("rect");
                $('#polygon').hide();
                $('#round').hide();
                $('#rectangle').show();
                break;

            case "Circle":
                // //// // // // // console.log("circle");
                $('#polygon').hide();
                $('#rectangle').hide();
                $('#round').show();
                $('#rad1label').text("Radius: ");
                $('#rad2').hide();
                break;

            case "Ellipse":
                $('#polygon').hide();
                $('#rectangle').hide();
                $('#round').show();
                $('#rad1label').text("Horiz. Radius: ");
                $('#rad2').show();
                break;
        }

    });

    // color picker dialog box. 
    $("#color_box").dialog({
        autoOpen: false,
        width: 230,
        listening: false,
        resizable: false,
        draggable: true,
        modal: false,
        show: 'fade',
        hide: 'fade',
    });
	
	// filename dialog box. 
	    // color picker dialog box. 
    $("#save_box").dialog({
        autoOpen: false,
        width: 500,
        listening: false,
        resizable: false,
        draggable: true,
        modal: false,
        show: 'fade',
        hide: 'fade',
		  buttons: [{
            text: "Save",
            click: function (event) {
				event.preventDefault();
                $(this).dialog("close");
				var myName = $("#my_filename").val();
				prepScreen(myName);
				
            }

        },
        {
            text: "Cancel",
            click: function (event) {
				event.preventDefault()
                $(this).dialog("close");

            }
        }]
    });
    $("#help_box").dialog({

        autoOpen: false,
        width: 400,
        minWidth: 400,
        height: 400,
        minHeight: 200,
        listening: false,
        resizable: true,
        draggable: true,
        scrollable: true,
        modal: false,
        show: 'fade',
        hide: 'fade',
    });

    //$("#help_box").draggable();
    $("#color_box").draggable();
    $("#color_box").dialog("option", "position", "center");

    $("#dimensions_dialog").dialog({
        autoOpen: false,
        width: 400,
        resizable: false,
        modal: true,
        show: 'fade',
        hide: 'fade',
        buttons: [{
            text: "Set Dimensions",
            click: function () {
                var myWidth = $('#roomWidth').val();
                var myHeight = $('#roomHeight').val();

                var nHeight = parseInt(myHeight);
                var nWidth = parseInt(myWidth);

                var maxHeight = 570;
                var maxWidth = 700;

                /* if ((nHeight > maxHeight || nHeight < 200) && (nWidth > maxWidth || nWidth < 200)) {
                    $('#error').text('Enter integers between 200 and 700.');
                } else */
                if (nHeight > maxHeight || nHeight < 200) {
                    $('#error').text('Make the height between 200 and 570.');
                } else if (nWidth > maxWidth || nWidth < 200) {
                    $('#error').text('Make the width between 200 and 700.');
                } else {
                    $(this).dialog("close");
                    $('#error').val('');
                    setDimensions(nWidth, nHeight);


                }


            }

        },

        {
            text: "Cancel",
            click: function () {
                $(this).dialog("close");
                buttonUp("#button1");
                defaultText();

            }
        }]

    });

    // cialog closure bindings

    $('#shape_box').bind('close', function (event, ui) {
        buttonUp("#button0");
		defaultText();

    });
    $('#image_box').bind('close', function (event, ui) {

        buttonUp("#button1");
		defaultText();

    });

    $('#input_box').bind('close', function (event) {

        buttonUp("#button2");
        defaultText();
    });

    $("#shape_box").dialog({
        autoOpen: false,
        width: 600,
        height: 440,
        resizable: false,
        modal: true,
        show: 'fade',
        hide: 'fade',


        buttons: [{

            text: "Place Shape",
            click: function () {
				
				if (checkShapeDim())
				{
                	$(this).dialog("close");


                	 var fill = $("#color7").spectrum("get");
                	 var stroke = $("#color8").spectrum("get");

               		 var hexFill = fill.toHex();

                	 var hexStroke = stroke.toHex();
				
                	addShape(hexFill, hexStroke);
				}


            }

        },

        {
            text: "Cancel",
            click: function () {
                $(this).dialog("close");
            }


        }]


    });
	
	$('#my_url').focus(function () {
		
		$('#image_feedback').text('');
		});
		
	$('#num_sides').focus(function () 
	{
		clearError();
	});
	$('#side_length').focus(function () 
	{
		clearError();
	});
	$('#width').focus(function () 
	{
		clearError();
	});
	$('#height').focus(function () 
	{
		clearError();
	});
	$('#radius1').focus(function () 
	{
		clearError();
	});
	
	function clearError()
	{
		$('#shape_error').text('');
	}
	function checkShapeDim()
	{
		  var shapeType = $("#shape_type input:checked").val();
		  
		 switch (shapeType) {
            case 'rPolygon':
			case 'iPolygon':
             
			 if ($('#num_sides').val() > 12)
			 {
				 $('#shape_error').text('Too many sides - maximum number is 12.')
				 return false;
			 }
			 else if($('#num_sides').val() < 3)
			 {
				 $('#shape_error').text('Not enough sides.')
				 return false;
			 }
			 else if (isNaN($('#num_sides').val()))
			 {
				 $('#shape_error').text('Enter a valid number of sides.')
				 return false;
			 }
			 else if ($('#num_sides').val() != Math.round($('#num_sides').val()))
			 {
				 $('#shape_error').text('Use an integer for number of sides.');
				 return false;
			 }
			 else if ($('#side_length').val() > 150)
			 {
				 $('#shape_error').text('Side length is too long.');
				 return false;
			 }
			 else if ($('#side_length').val() < 5)
			 {
				 $('#shape_error').text('Side length is too short.');
				 return false;
			 }
			 else if (isNaN($('#side_length').val()))
			 {
				 $('#shape_error').text('Enter a valid side length.');
				 return false;
			 }
			 else
			 {
				 $('#shape_error').text('');
				 return true;
			 }
			 
               break;
        

            case 'Rectangle':
              
			  
			 if ($('#width').val() > 200 || $('#width').val() < 5)
			 {
				 $('#shape_error').text('Width should be between 5 and 200.')
				 return false;
			 }
			 else if (isNaN($('#width').val()))
			 {
				 $('#shape_error').text('Enter a valid number for width.')
				 return false;
			 }
			 else if ($('#height').val() > 200 || $('#height').val() < 5)
			 {
				 $('#shape_error').text('Height should be between 5 and 200.');
				 return false;
			 }
			 else if (isNaN($('#side_length').val()))
			 {
				 $('#shape_error').text('Enter a valid number for height.');
				 return false;
			 }
			 else
			 {
				 $('#shape_error').text('');
				 return true;
			 }

             break;
				
			case 'Circle': 
				
			if ($('#radius1').val() > 200 || $('#radius1').val() < 5)
			 {
				 $('#shape_error').text('Radius should be between 5 and 200.')
				 return false;
			 }
			 else if (isNaN($('#radius1').val()))
			 {
				 $('#shape_error').text('Enter a valid number for radius.')
				 return false;
			 }
			 else
			 {
				 $('#shape_error').text('');
				 return true;
			 }
			 break;
		 }
		
	}
    function checkLink(myURL) {
        return (myURL.match(/\.(jpeg|jpg|gif|png)$/) != null);
    }
	

    function testLoad(url, timeout) {
        timeout = timeout || 5000;
        var timedOut = false,
            timer;
        var img = new Image();
	//	img.crossOrigin = 'anonymous'; 
        img.onerror = img.onabort = function () {
            if (!timedOut) {
                clearTimeout(timer);
                //callback(url, "error");
                $("#image_feedback").text('The image could not load.');
                return false;
            }
        };
        img.onload = function () {
            if (!timedOut) {
                clearTimeout(timer);

                checkSize(img, url);
                return true;
            }
        };
        img.src = url;
        timer = setTimeout(function () {
            timedOut = true;
            $("#image_feedback").text('The operation timed out.');
            return false;
        }, timeout);

    }

    function checkSize(img, url) {


        var myWidth = img.width;
        var myHeight = img.height;

        if (myWidth > 400 || myHeight > 400) {
			resizeImage = img;
		//	resizeImage.crossOrigin = 'anonymous'; 
            $("#image_feedback").text("Image is too large, so it will be resized. Proceed?");
        } 
		else 
		{
			img.crossOrigin = 'anonymous'; 
			resizeImage = null;
            createCustomItem(img, url, myWidth, myHeight);
            $("#image_box").dialog("close");
        }

    }


    $("#image_box").dialog({
        autoOpen: false,
        width: 650,
        height: 370,
        resizable: false,
        modal: true,
        show: 'fade',
        hide: 'fade',


        buttons: [{

            text: "Place Image",
            click: function () {
				
				if (resizeImage == null)
				{
              	  var myURL = $("#my_url").val();

               	 if (checkLink(myURL))
                    testLoad(myURL, 5000)
                	else
                    	$('#image_feedback').text('This is not a valid image URL.')
                
				}
				else
				{
					addResizedImage();
				}

            }

        },

        {
            text: "Cancel",
            click: function (event) {
				event.preventDefault();
                $(this).dialog("close");
            }


        }]


    });

    // this box is for entering text that will appear on the classroom map. 
    $("#input_box").dialog({
        autoOpen: false,
        width: 750,
        height: 400,
        resizable: false,
        modal: true,
        show: 'fade',
        hide: 'fade',
        open: function () {

            $(this).find('button:first').css('margin', '0px');
            $(this).find('button:last').css('margin', '0px');


        },
        buttons: [{
            text: "Submit",
            click: function (event) {
				event.preventDefault();
                $(this).dialog("close");

                (textbg == true) ? createTextBox() : createText();
            }

        },

        {
            text: "Cancel",
            click: function (event) {
				event.preventDefault()
                $(this).dialog("close");

            }
        }]

    });

    // this function clears the input field when the box is closed. 
    $('#input_box').bind('dialogclose', function () {
        $('#enter_text').val('');
    });

    init();

    function init() {
        setColorPickers();

        showPolygonOptions();
        setLayers();



        mapLayers();
		
		addListeners();
    }
	function addListeners()
	{
		$('#no_capture a').click(function () {
			
			 	var myPanel = stage.get('#topPanel')[0];
		
      			var mySpace = stage.get('#whitespace')[0];
				  
				showMyTools(mySpace, myPanel);
				
				$('#no_capture').css('visibility','hidden');
			
			});
	}
	function addResizedImage()
	{
		var img = resizeImage;
					
		var myWidth = img.width;
        var myHeight = img.height;
					
		var divisor;
					
		if (myWidth >= myHeight)
			divisor = myWidth/400;
		else
			divisor = myHeight/400;
						
		myWidth /= divisor;
					
		myHeight /= divisor;
			
		//img.crossOrigin = 'anonymous'; 
		
		createCustomItem(img, img.src, myWidth, myHeight);
		
		$("#image_box").dialog("close");
		   	
		resizeImage = null;
	}
    function mapLayers() {
        // add art groups to art layer.

        artLayer.add(artGroup0); // for carpets and floor items

        artLayer.add(artGroup1); // for chairs

        artLayer.add(artGroup2); // tables, desks, windows, boards

        artLayer.add(artGroup3); // computers, projection screens

        // artLayer.add(textGroup); // text bubbles

    }

    function toolButtonToggle(bool) {
        for (i = 0; i < 4; i++) {
            var myButton = stage.get("#button" + i)[0];
            myButton.setVisible(bool)
        }
    }

    // binds save-as-image function to the 'save' button. 
    function showMyTools(mySpace, myPanel) {

        $('#instructions').show();
        myPanel.setVisible(true);
        toolButtonToggle(true);
        toolButtonLayer.show();
        messageLayer.show();
        paletteLayer.show();

        paletteLayer.draw();
        boardLayer.draw();

        mySpace.show();
        boardLayer.draw();
        toolButtonLayer.draw();
		
		boardLayer.setX(0);
		boardLayer.draw();
		artLayer.setX(0);
		artLayer.draw();
		textLayer.setX(0);
		textLayer.draw();

    }

    function hideMyTools(mySpace, myPanel, centerIt) {
		
		boardLayer.setX(centerIt);
		boardLayer.draw();
		artLayer.setX(centerIt);
		artLayer.draw();
		textLayer.setX(centerIt);
		textLayer.draw();
		
        $('#instructions').hide();
        toolButtonLayer.hide();
        myPanel.setVisible(false);
        toolButtonToggle(false);
        messageLayer.hide();
        boardLayer.draw();

        paletteLayer.hide();
        paletteLayer.draw();

        mySpace.hide();
        boardLayer.draw();
        toolButtonLayer.draw();
		
		
    }

    function captureImage() {

    
		

 
		
		// TO DO: if customImages > 0, add the message and allow for a screenshot. 
		if (customImages > 0)
		{
			$('#no_capture').css('visibility','inherit');
		}
		else
		{
			if (BrowserDetect.browser == 'Firefox' || BrowserDetect.browser == 'Chrome')
			{
				console.log('yes');
				openSaveBox();
			}
			else
			{
				prepScreen("my-Image");
				
			}
		}
	
    }
	function prepScreen(myName)
	{
				var myPanel = stage.get('#topPanel')[0];

       			var mySpace = stage.get('#whitespace')[0];
		
				var centerIt = -40;
			    hideMyTools(mySpace, myPanel, centerIt);
				dataURL(mySpace, myPanel, myName);
	}
	
	function openSaveBox()
	{
		$('#save_box').dialog("open");
	}
	function dataURL(mySpace, myPanel, myName)
	{
		console.log("dataurl");
			setTimeout(function () {
			showMyTools(mySpace, myPanel)
			}, 2000);
        stage.toDataURL({
			
			
            callback: function (dataUrl) {
				
				if (BrowserDetect.browser == 'Firefox' || BrowserDetect.browser == 'Chrome')
				{
					var canvas = document.getElementById("myCanvas"), ctx = canvas.getContext("2d");
				
				
				var img = new Image;
				img.onload = function(){
 				 ctx.drawImage(img,0,0); // Or at whatever offset you like
				 
				 canvas.toBlob(function(blob) {
    			saveAs(blob, myName + ".png");
					
					ctx.clearRect(0, 0, canvas.width, canvas.height);
});
				};
				img.src = dataUrl;
				}
				else
				{
					window.open(dataUrl);
				}
          
	  
                setTimeout(function () {
					showMyTools(mySpace, myPanel);
				}, 2000);
            },
            mimeType: 'image/png',
            quality: 1
        });
	}
    /*
     *   GETS THE SELECTED SHAPE IN THE TEXTBOX. 
     */
    function addShape(hexFill, hexStroke) {
       

        var shapeType = $("#shape_type input:checked").val();

        switch (shapeType) {
            case 'rPolygon':
                addPolygon(hexFill, hexStroke, 'reg');
                break;
            case 'iPolygon':
                addPolygon(hexFill, hexStroke, 'irreg');
                break;

            case 'Rectangle':
                addRectangle(hexFill, hexStroke, 'rect');
                break;
				
			case 'Circle': 
				addCircle(hexFill, hexStroke, 'circle');
				// //// // // // // console.log('making circle');
				break;
            default:
                // //// // // // // console.log('no shape yet!');
                break;
        }

    }

    /*
     * Sets the behavior for each note. 
     */
    function checkMode(obj) {
			// // // // // console.log("checkmode");

        if (toolMode == 'eraser') {
            var myLayer = obj.attrs.homeLayer;
            var myID = '#' + obj.attrs.id;


            if (obj.attrs.name == 'shape') {
                var nm = obj.attrs.id;

                // gete the shape in the group
                var myNumber = nm.substring(8, nm.length);
				
				
				
				var anchors = stage.get('.anchor'+myNumber);
				
				deleteAnchors(anchors)
				
				

                var shapeID = '#myShape' + myNumber;

                // get the index of the id
                var shapeIndex = shapeArray.indexOf(shapeID);

                // splice the array at the end
                shapeArray.splice(shapeIndex, 1);

            }
            var myObj = stage.get(myID)[0];

             obj.destroy();


            myLayer.draw();

            stage.draw();
			
			// //// // // // // console.log("object array before splice: " + objectArray);
			
            var myIndex = objectArray.indexOf(myID);

            objectArray.splice(myIndex, 1);

            // //// // // // // console.log("objects array after splice: " + objectArray);


        } else if (toolMode == 'rotate' && obj.attrs.name != 'shape') {
            rotate45(obj);
        } else if (toolMode == 'resize' && obj.attrs.name != 'shape') {
            
                currentTarget = obj;
              
				allSolid();
				
                artLayer.draw();
			
                textLayer.draw();
          
        }

    }


    function rotate45(obj) {

        var myLayer = obj.attrs.homeLayer;

        var diffRadians = Math.PI / 4;

        var angularSpeed = diffRadians; //(Math.PI/2);

        var frameCount = 0;
        var anim = new Kinetic.Animation(function (frame) {

            frameCount++;

            var angleDiff = angularSpeed; //frame.timeDiff * angularSpeed/1000;

            if (frameCount > 1) {
                anim.stop();
                myLayer.draw();
                stage.draw();
                return 0;
            }

            obj.rotate(angleDiff);
            obj.attrs.angle += angleDiff;

            if (obj.attrs.angle > Math.PI * 2) {
                obj.attrs.angle -= Math.PI * 2;
            } else if (obj.attrs.angle < 0) {
                obj.attrs.angle += Math.PI * 2;
            }

        }, myLayer);

        anim.start();




    }


function rotateImage(number, myDiff) {

		var obj = stage.get('#myShape'+number)[0];
		
        var myLayer = obj.attrs.homeLayer;

        var diffRadians = -myDiff/4;

        var angularSpeed = diffRadians; //(Math.PI/2);

        var frameCount = 0;
        var anim = new Kinetic.Animation(function (frame) {

            frameCount++;

            var angleDiff = angularSpeed; //frame.timeDiff * angularSpeed/1000;

            if (frameCount > 1) {
                anim.stop();
                myLayer.draw();
                stage.draw();
                return 0;
            }

            obj.rotate(angleDiff);
            obj.attrs.angle += angleDiff;

            if (obj.attrs.angle > Math.PI * 2) {
                obj.attrs.angle -= Math.PI * 2;
            } else if (obj.attrs.angle < 0) {
                obj.attrs.angle += Math.PI * 2;
            }

        }, myLayer);

        anim.start();




    }
    /*
     *  Make all buttons solid and non-rotating
     */

    function allSolid() 
	{
     
		
		
        for (var i = 0; i < objectArray.length; i++) 
		{
            var myID = objectArray[i];
            var myObj = stage.get(myID)[0];

            var myLayer = myObj.attrs.homeLayer;
	
			
         if (myObj != currentTarget && myObj) 
		 {
			 	myObj.setDraggable(true);
                myObj.setOpacity(1);
				myLayer.draw();
				artLayer.draw();
				stage.draw();
				
			   
          }
        }
	    if (currentTarget)
		{
			currentTarget.setDraggable(false)
			currentTarget.setOpacity(0.5);
			stage.draw();
		}
		
		 
		// //// // // // // console.log("********");

    }
    /*
     * Clears all objects from the map
     */
    function clearMap() {
        var n = objectArray.length;

        for (var i = 0; i < n; i++) {
            var myID = objectArray[i]

            var myObj = stage.get(objectArray[i])[0];
            //pseudo-removal of object

            myObj.setAttrs({
                visible: false,
                x: 0,
                y: 0,
                draggable: false
            });
        }

		artLayer.draw();
              
        while (objectArray.length > 0)
        objectArray.splice(0, 1);


    }


    function setBasics(myItem) {
		// // // // // console.log("setting basics");
        myItem.on('mousemove', function () {

            if (isDown) tooltip.hide();
        });
        myItem.on('touchmove', function () {

            tooltip.hide();
        });
        // when touch or mousedrag starts, the palette is not draggable. 
        myItem.on('tap click', function () {
			// // // // // console.log("TAP CLICK");
           if (!myItem.attrs.firstDrag) checkMode(myItem);
        });


        // cursor changes style upon hovering over the palette. 
        cursorStyle(myItem);
    }

    function setBehavior(myItem) {
        setBasics(myItem);

        // when we start dragging, let's disable dragging of the palette and add a note below the current note. 
        myItem.on('dragstart', function () {
			
			// // // // // console.log("dragstart");
            // if we are not in the middle of adding a note, let's add one!
            if (addingNote == false) prepareItem(this);
            tooltip.hide();
            tooltipLayer.draw();

        });



        myItem.on('dragend', function () {
				// // // // // console.log("dragend");
            // on the first drag, we need to compensate for the change in coordinate systems
            if (this.attrs.firstDrag == true) 
			{
                artLayer.draw();
                checkItemSize(myItem);


                this.attrs.x += paletteLayer.getX();
                this.attrs.y += paletteLayer.getY();

                artLayer.draw();
                paletteLayer.draw();

                if (!this.attrs.large) {
                    pushObject(myItem.attrs.id);
                    objectCounter++;
                }
            }
            this.attrs.firstDrag = false;

        });

    }

    function checkItemSize(thisItem) {
        if (thisItem.attrs.large) {
            var mySrc = thisItem.attrs.src;
            var largeVersion = new Image();
            largeVersion.src = mySrc.substring(0, mySrc.length - 4) + "_large.png",

            largeVersion.onload = function () {

                createLargeItem(this, thisItem, mySrc);
                artLayer.draw();
            };


        } else {
            moveToLayer(thisItem)
        }
    }

    function createLargeItem(imageObj, thisItem, mySrc) {
        
		// // // // // console.log("createLargeItem");
        var myItem = new Kinetic.Image({
            image: imageObj,
            x: thisItem.getX()+thisItem.attrs.width/2,
            y: thisItem.getY()+thisItem.attrs.height/2,
            z: thisItem.attrs.z,

            width: thisItem.attrs.width,
            height: thisItem.attrs.height,

            targetWidth: thisItem.attrs.width2,
            targetHeight: thisItem.attrs.height2,
            dragOnTop: false,
            src: mySrc,
            draggable: true,
            firstDrag: false,
            offset: [thisItem.attrs.width, thisItem.attrs.height],
            rotating: false,
            homeLayer: artLayer,
            angle: 0,
            id: 'myObject' + objectCounter,

        });
		// // // // // console.log("item declared");
        //myItem.setOffset(myItem.getWidth() / 2, myItem.getHeight() / 2);

        pushObject(myItem.attrs.id);
		
		//dragWithinStage(myItem);
        objectCounter++;

 		

        addingNote = false;

		//paletteLayer.add(myItem);
      addToLayer(myItem);
		  thisItem.remove();

       
    //    paletteLayer.draw();
      //	  stage.draw();

		setBasics(myItem);
       enlarge(myItem)
	  
	
		 stage.draw();
		//	// // // // // console.log("drawn");
    }
    function getCurrentWidth(id) {
        var myObj = stage.get(id)[0];
        var myWidth = myObj.attrs.width * myObj.getScale().x;
        return myWidth;
    }

    function getCurrentHeight(id) {
        var myObj = stage.get(id)[0];
        var myHeight = myObj.attrs.height * myObj.getScale().y;
        return myHeight;
    }
	
	
	function dragWithinStage(myItem)
	{
		 myItem.setDragBoundFunc(function (pos) {
			 	var myFloor = stage.get('#wall4')[0];
                var rightEdge = leftEdge + myFloor.attrs.width;
                var botEdge = topEdge + myFloor.attrs.height;
                var myID = '#' + this.attrs.id;
				
				var cw = getCurrentWidth(myID);
				var ch = getCurrentHeight(myID);
				
				var thisWidth;
				var thisHeight;
				
				var myAngle = parseFloat(myItem.attrs.angle);
				
				if (radDeg(myAngle) == 0 || radDeg(myAngle) == 180) // if 0 or 180
				{
                	thisWidth = cw;
                	thisHeight = ch;
				
				}
				else if (radDeg(myAngle) == 90 || radDeg(myAngle) == 270)
				{
					thisWidth = ch;
					thisHeight = cw;
						
				}
				else // 45 degree angle
				{
					var boxSide = ch*Math.cos(Math.PI/2) + cw*(Math.sin(Math.PI/2));
				
					thisWidth = boxSide; //Math.abs(cw*(Math.cos(Math.PI/2))) + Math.abs(ch*(Math.cos(Math.PI/2)));
					thisHeight = boxSide;
				
				
				}
				var newY;
				var newX;
				
				if (this.getX() > leftEdge+10)
				{
                newY = pos.y > botEdge - thisHeight / 2 ? botEdge - thisHeight / 2 : pos.y;
                newX = pos.x < leftEdge + thisWidth / 2 ? leftEdge + thisWidth / 2 : pos.x;

                if (pos.x > rightEdge - thisWidth / 2) newX = rightEdge - thisWidth / 2;

                if (pos.y < topEdge + thisHeight / 2) newY = topEdge + thisHeight / 2;
				}
				else
				{
					newY = pos.y;
					newX = pos.x;
				}

                return {
                    x: newX,
                    y: newY
                }
            });
	}
    function createCustomItem(imageObj, mySrc, myWidth, myHeight) {
        var myFloor = stage.get('#wall4')[0];

		var centerX = stage.attrs.width/2;
		var centerY = stage.attrs.height/2;
		
        var myItem = new Kinetic.Image({	
            image: imageObj,
            x: centerX,
            y: centerY,
            z: 3,
			wasX: 0,
			wasY: 0,
            width: myWidth,
            height: myHeight,
            dragOnTop: false,
            src: mySrc,
            draggable: true,
            firstDrag: false,
            rotating: false,
            homeLayer: artLayer,
            angle: 0,
			number: objectCounter,
            id: 'myShape' + objectCounter,
			name: 'shape'
			// encapsulate this in a function and use for all objects. 
        });

		dragWithinStage(myItem);
		
        myItem.setOffset(myItem.getWidth() / 2, myItem.getHeight() / 2);

		var points = rectPoints(myWidth, myHeight, centerX, centerY);
		
		addToLayer(myItem);
		
		rectAnchors(points, myItem, 'reg-image')
		
		myItem.moveUp();
		
		// adds to shape array for showing / hiding / color change
		pushShape(myItem.attrs.id);
		
        pushObject(myItem.attrs.id);
		
        objectCounter++;
		
		
		customImages++;

        setBasics(myItem); // probably should delete this
		
		// anchors move along with item.
        addingNote = false;
		
		shapeStartLoc(myItem, centerX, centerY);
		
		shapeBehavior(myItem.attrs.number);

        stage.draw();

    }

    function enlarge(myItem) {

        var tWidth = myItem.attrs.targetWidth;
        var tHeight = myItem.attrs.targetHeight;

        var moveY = (tHeight - myItem.attrs.height) / 2;
        var moveX = (tWidth - myItem.attrs.width) / 2;

        var newX = myItem.getX() - tWidth / 4;
        var newY = myItem.getY() - tHeight / 4;
		
		//myItem.attrs.x = newX;
		
		//myItem.attrs.y = newY;
		
		var tween = new Kinetic.Tween({
			
			
			node: myItem,
			width:tWidth,
			height:tHeight,
			easing: Kinetic.Easings.EaseInOut,
			duration: 1
		
			
			
			})
			
			tween.play();
			artLayer.draw();

     /*   myItem.transitionTo({
            width: tWidth,
            height: tHeight,
            x: newX,
            y: newY,


            duration: 1,

            easing: 'elastic-ease-out',
            callback: function () {

               window.setTimeout(function () {
                    moveItem(myItem, moveX, moveY, tWidth, tHeight)
					
					
					
                }, 1000);



                //moveItem(myItem, tWidth, tHeight);
            }



        });*/
    }

    function moveItem(myItem, moveX, moveY, tWidth, tHeight) {
        myItem.setOffset(tWidth / 2, tHeight / 2);
        myItem.attrs.x += moveX;
        myItem.attrs.y += moveY;
        paletteLayer.draw();
        artLayer.draw();
        stage.draw();
    }

    function addToLayer(myItem) {
		// // // // // console.log("addToLayer");
        switch (myItem.attrs.z) {
            case 0:
				// // // // // console.log("artgroup0");
                artGroup0.add(myItem);
                break;
            case 1:
				// // // // // console.log("artgroup1");
                artGroup1.add(myItem);
                break;
            case 2:
				// // // // // console.log("artgroup2");
                artGroup2.add(myItem);
		
			
                break;
            case 3:
				// // // // // console.log("artgroup3");
                artGroup3.add(myItem);
                break;
        }
        artLayer.draw();
	
    }

    function moveToLayer(thisItem) {
        switch (thisItem.attrs.z) {
            case 0:
                thisItem.moveTo(artGroup0);
                break;
            case 1:
                thisItem.moveTo(artGroup1);
                break;
            case 2:
                thisItem.moveTo(artGroup2);
                break;
            case 3:
                thisItem.moveTo(artGroup3);
                break;
        }
    }

    function addShadow(obj, myLayer) {

        obj.attrs.shadow = {
            color: 'black',
            blur: 10,
            offset: [40, 40],
            opacity: 1
        };
        myLayer.draw();
    }

    function deleteShadow(obj, myLayer) {
        obj.attrs.shadow = null;
        myLayer.draw();
    }

    function locToIndex(locY) {
        var index = parseInt((locY - 10) / 45) - 1;
        return index;
    }
    // prepares the next note. 
    function prepareItem(obj) {
        addingNote = true;
        obj.off('dragstart');


        obj.moveToTop();

        var nextNote = new Image();




        // specify the source image for the item

        nextNote.src = obj.attrs.src;

        // get the properties of the parent item
        var locY = obj.attrs.origY;
        var locX = obj.attrs.origX;
        var locZ = obj.attrs.z;

        var myWidth = obj.attrs.width;
        var myHeight = obj.attrs.height;
        var myName = obj.attrs.name;

        var myLabel = obj.attrs.label;
        var myWidth2 = obj.attrs.width2;
        var myHeight2 = obj.attrs.height2;
        var myLarge = obj.attrs.large;

        // when the image is loaded, call the addNote() function
        nextNote.onload = function () {
            addNewItem(this, locY, locX, locZ, myWidth, myHeight, myWidth2, myHeight2, myLabel, myLarge, this.src, myName);
            paletteLayer.draw();
        };

    }

    function addNewItem(imageObj, locY, locX, locZ, myWidth, myHeight, myWidth2, myHeight2, myLabel, myLarge, src, myName) {
        var offY = myHeight / 2;
        var offX = myWidth / 2;

        // create a temporary layer
        // var tempLayer = new Kinetic.Layer();
        //var locX = rect.attrs.x + 30;
        // set the properties of the 
        var myItem = new Kinetic.Image({
            image: imageObj,
            x: locX,
            y: locY,
            z: locZ,
            origX: locX,
            origY: locY,
            large: myLarge,
            label: myLabel,
            width2: myWidth2,
            height2: myHeight2,
            width: myWidth,
            height: myHeight,
            offset: [offX, offY],
            src: src,
            opacity: 1,
            draggable: true,
            firstDrag: true,
            dragOnTop: false,
            rotating: false,
            homeLayer: artLayer,
            angle: 0,
            name: myName,
            id: 'myObject' + objectCounter
        });

        addTip(myItem);
        addToPanelGroup(myName, myItem);

        myItem.moveToTop();
        // add temp Layer to the stage
        //stage.add(tempLayer);

        // move temp layer to the bottom
        // tempLayer.moveToBottom();

        // sets button mode for note
        setBehavior(myItem);

        myItem.moveDown();
		
		dragWithinStage(myItem);

        //stage.destroy(tempLayer);

        ///  notesGroup.moveToBottom();

        addingNote = false;

        // this is not added to the array, but each object needs a unique id
        objectCounter++;


    }

    // push new object into the array
    function pushObject(id) {
		
		// //// // // // // console.log("object array before push: " + objectArray);
        label = '#' + id;
        objectArray.push(label);
		
		// //// // // // // console.log("object array after push: " + objectArray);

    }

    function pushShape(id) {
        label = '#' + id;
        shapeArray.push(label);
    }

    // orient layers and draw the classroom stage. 
    function setLayers() {

        var myWidth = 700;
        var myHeight = 570;

        drawItemPanel(myWidth, myHeight);
        drawClassroom(myWidth, myHeight);
        // add image to layer



        // add layer to stage
        stage.add(boardLayer);

        stage.add(artLayer);

        stage.add(textLayer);

        stage.add(paletteLayer);

        stage.add(toolButtonLayer);

        tooltipLayer.add(tooltip);

        stage.add(tooltipLayer);


		tooltipLayer.moveToTop();

        // move the board layer to the bottom

        boardLayer.setZIndex(0);
    }



    /*
     *  SET UP ITEMS PALETTE
     */
    // draws one item button on the item palette
    function drawItemButton(obj, myX, myY, i) {

        var imageObj = new Image();

        imageObj.onload = function () {

            var btn = new Kinetic.Sprite({
                x: myX,
                y: myY,

                image: imageObj,
                animation: 'objectUp',
                animations: itemButtons[i],
                frameRate: 2,
                id: 'itembutton' + i


            });

            if (i == 0) {
                btn.setAnimation('objectDown');
            }
            btn.on('mousedown click tap touchstart', function () {

                panelPress(btn);
            });


            navGroup.add(btn);

            itemCounter++;

            if (itemCounter == itemButtons.length) {
                itemCounter = 0;

                paletteLayer.add(navGroup);

                populatePanel();

                paletteLayer.draw();
            }
        }

        imageObj.src = "images/item_buttons.png";


        // paletteLayer.setDraggable(true);





    }

    /*
     * Toolbar buttons
     */
    function drawToolbutton(obj, myX, myY, i) {
        var imageObj = new Image();


        imageObj.onload = function () {

            var btn = new Kinetic.Sprite({
                x: myX,
                y: myY,

                // get the image
                image: imageObj,

                // set the starting frame
                animation: 'objectUp',

                // get the correct animation frames from the sprite sheet
                animations: toolbarButtons[i],
                frameRate: 2,
                id: 'button' + i
            })

            // the object button is down first

            toolCounter++;

            toolButtonLayer.add(btn);

            toolButtonLayer.draw();



            //boardLayer.draw();

            cursorStyle(btn);

            btn.on(' mousedown touchstart', function () {
                toolbarPress(btn);
				
				
				
            });

            btn.on('mouseover', function () {
                if (!tooltip.attrs.visible) {
                    timer1 = setTimeout(function () {
                        tooltip.show();
                        tooltipLayer.draw();
                    }, 1000)
                }
            });
            // tool tip functionality - show tip on mouse over
            btn.on('mousemove', function () {
                showToolTip(tips[i])
            });

            btn.on('mouseout', function () {
                tooltip.hide();

                tooltipLayer.draw();
                clearTimeout(timer1);
            });

        };
        imageObj.src = "images/toolbar_buttons.png";

    }
	
	function multiLine()
	{
			$("#instructions").css('top', '14px');
	}
	function singleLine()
	{
		$("#instructions").css('top', '20px');
	}
    function defaultText() {
		singleLine();
        $("#instructions").text("Populate your classroom by adding objects to the map.");
    }

    // switches tool modes when button is pressed. 
    function activateTool(obj) {

        switch (obj.attrs.id) {
            // object

            // shapes
            case 'button0':
                toolMode = 'shape';
				singleLine();
                $("#instructions").text("Choose shape type and properties.");
                $('#shape_box').dialog("open");
                break;
                // image
            case 'button1':
                toolMode = 'image';
				singleLine();
                $("#instructions").text("Enter an image URL.");
                $('#image_feedback').val('');
                $('#image_box').dialog("open");
                break;

                // text
            case 'button2':
                toolMode = 'text';
				singleLine();
                $("#instructions").text("Enter your text.");
                $('#input_box').dialog("open");

                break;
                // eraser
            case 'button3':
				singleLine();
                $("#instructions").text("Click on or tap an object to erase it.");

                //iText.setOffset(iText.getWidth()/2, iText.getHeight/2);
                paletteLayer.draw();
                toolMode = 'eraser';
                break;



                // rotate
            case 'button4':
			    multiLine();
                $("#instructions").html(newLines("Click an object to rotate it by 45 degrees clockwise.\nFor shapes and custom images, rotate using their anchors."));
                toolMode = 'rotate';
                anchorColors('#76e041', true);
                break;

                // resize
            case 'button5':
				multiLine();
                toolMode = 'resize';
                $("#instructions").html(newLines("Click or tap an object, and swipe up or down to resize.\nFor shapes and custom images, resize using their anchors."));
                anchorColors('#dddddd', true);

                break;

        }
        boardLayer.draw();
    }

    function toolOff(obj) {

		currentTarget = null;
        toolMode = null;
		 allSolid();
        
       
        artLayer.draw();
		textLayer.draw();

        anchorColors('#dddddd', false); //change to false


    }


    // specficially makes text button revert to up position; used when dialog box is closed. 
    function buttonUp(buttonName) {
        var myButton = stage.get(buttonName)[0];
        myButton.setAnimation('objectUp');
        stage.draw();
        currentTarget = null;
        // turn off rotate
        if (buttonName == '#button4') {
            // //// // // // // console.log("turn off rotate");
            anchorColors('#dddddd', false);
        }


    }

    function hideAll(id) {
        if (id != "itembutton0") techGroup.hide();

        if (id != "itembutton1") furnGroup.hide();

        if (id != "itembutton2") winGroup.hide();
    }

    function panelPress(obj) {
        if (obj.attrs.animation == 'objectUp') {
            for (var e = 0; e < 3; e++) {
                buttonUp('#itembutton' + e);


            }
            switchGroup(obj.attrs.id);

            obj.setAnimation('objectDown');
            paletteLayer.draw();

        }
    }

    function switchGroup(id) {
        hideAll(id);

        switch (id) {
            case "itembutton0":
                techGroup.show();
                break;
            case "itembutton1":
                furnGroup.show();
                break;
            case "itembutton2":
                winGroup.show();
                break;

        }
        paletteLayer.draw();
    }

    function toolbarPress(obj) {

        if (obj.attrs.animation == 'objectUp') {
            for (var e = 0; e < 6; e++) {
                var bName = '#button' + e;
                if (obj.attrs.id != bName);
                buttonUp(bName);
                toolButtonLayer.draw();
            }


            obj.setAnimation('objectDown');

            toolButtonLayer.draw();


            activateTool(obj);
			
			currentTarget = null;
			allSolid();
        } else if (obj.attrs.animation == 'objectDown') {

            obj.setAnimation('objectUp');
            toolOff(obj);
            toolButtonLayer.draw();
            defaultText();
        }
    }



    /*
     * Create new item panel
     */

    function setItemPanel() {


        //	cursorStyle(itemGroup);


        paletteLayer.add(techGroup);

        paletteLayer.draw();

        paletteLayer.add(winGroup);

        paletteLayer.add(furnGroup);

        paletteLayer.add(wallGroup);





        tooltipLayer.moveToTop();

        textLayer.setZIndex(2);


        paletteLayer.draw();

        switchGroup('itembutton0');

        window.setTimeout(function () {
            drawMe()
        }, 500)

        return 0;


    }

    function drawMe() {


        paletteLayer.draw();
    }

    function drawItemPanel(myWidth, myHeight) {

        var rightEdge = leftEdge + myWidth;
        var botEdge = topEdge + myHeight;


        var infoScreen = new Kinetic.Rect({
            x: 210,
            y: 12,
            width: 400,
            height: 48,
            strokeWidth: 1,
            cornerRadius: 10,
            draggable: false,
            fillLinearGradientStartPoint: [0, 0],
            fillLinearGradientEndPoint: [0, topEdge],
            fillLinearGradientColorStops: [0, '#fff', 1, '#69f'],

            id: 'infoPanel'


        });
        var whiteSpace = new Kinetic.Rect({

            x: leftEdge,
            y: topEdge,
            width: myWidth,
            height: myHeight,
            fill: '#fff',
            stroke: '#000',
            strokeWidth: 1,
            id: 'whitespace'

        });

        var topPanel = new Kinetic.Rect({

            x: 10,
            y: 0,
            width: rightEdge - 10,
            height: topEdge,
            fillLinearGradientStartPoint: [0, 0],
            fillLinearGradientEndPoint: [0, topEdge],
            fillLinearGradientColorStops: [0, '#dedede', 1, '#aaa'],
            stroke: 'black',
            strokeWidth: 1,
            id: 'topPanel'



        });
        var leftPanel = new Kinetic.Rect({

            x: 10,
            y: topEdge,
            width: leftEdge - 10,
            height: botEdge - topEdge,
            //fill: '#909baf',
            // set the gradient
            fillLinearGradientStartPoint: [0, 0],
            fillLinearGradientEndPoint: [leftEdge + 100, 0],
            fillLinearGradientColorStops: [0, '#dedede', 1, '#aaa'],
            // fillLinearGradientColorStops: [0, '#909baf', 1, '#a4abba'],
            strokeWidth: 1,
            draggable: false,
            name: 'itemsPanel',
            id: 'itemsPanel'
        });
		
		paletteLayer.add(leftPanel);
        paletteLayer.add(topPanel);
      

        paletteLayer.add(infoScreen);
        paletteLayer.draw();
        boardLayer.add(whiteSpace);
        boardLayer.draw();




        // add navigation buttons
        for (var i = 0; i < itemButtons.length; i++) {
            // position button sprite
            var btnX = leftPanel.getX() + 10;
            var btnY = leftPanel.getY() + 20 + 25 * i;

            drawItemButton(leftPanel, btnX, btnY, i);

        }
        // add navigation buttons
        for (var i = 0; i < toolbarButtons.length; i++) {

            var pushRight = (i < 3) ? 20 : 450;

            var btnX = pushRight + 60 * i;
            var btnY = topPanel.getY() + 12;

            drawToolbutton(leftPanel, btnX, btnY, i);




        }


    }

    function addItemGroup(myData, groupType, totalItems) {
        $.each(myData, function (obj) {

            var myFile = "images/" + this.filename;
            var myWidth = this.width;
            var myHeight = this.height;
            var myHeight2 = this.height2;
            var myWidth2 = this.width2;
            var myLarge = this.large;
            var myLabel = this.label;
            var myX = this.x;
            var myY = this.y;
            var myZ = this.z;


            var groupID = "techgroup";

            var myItem = new Image();
            myItem.src = myFile;

            myItem.onload 
			{
                var thisItem = createItem(myX,
                myY,
                myZ,
                myWidth,
                myHeight,
                myFile,
                myItem,
                groupType,
                myLarge,
                myWidth2,
                myHeight2,
                myLabel)

                addToPanelGroup(groupType, thisItem);

                finalizeItem(thisItem, totalItems);


            }
        });
    }

    function addToPanelGroup(groupType, thisItem) {
        switch (groupType) {
            case "tech":
                techGroup.add(thisItem);
                break;

            case "win":
                winGroup.add(thisItem);
                break;

            case "furn":
                furnGroup.add(thisItem);
                break;


        }
    }

    function populatePanel() {
        // access the data from teh JSON file
        $.getJSON('js/json/items.txt', function (data) {
            var totalItems = data.tech.length + data.furniture.length + data.windows.length;

            // add the various item groups
            addItemGroup(data.tech, "tech", totalItems);

            addItemGroup(data.furniture, "furn", totalItems);

            addItemGroup(data.windows, "win", totalItems);


        });

    }

    function finalizeItem(thisItem, totalItems) {
        setBehavior(thisItem)

        itemTypeCounter++;
		
		objectCounter++;

        paletteLayer.draw();

        if (itemTypeCounter >= totalItems) window.setTimeout(function () {
            setItemPanel()
        }, 200)
		
		dragWithinStage(thisItem);
		
        addTip(thisItem);
    }

    // tool tip logic
    function addTip(thisItem) {
        thisItem.on('mouseover', function () {
            if (!tooltip.attrs.visible && thisItem.attrs.firstDrag && thisItem.getX() < 80 && !isDown) {
                timer1 = setTimeout(function () {
                    tooltip.show();
                    tooltipLayer.draw();
                }, 500)
            }
        });
        // tool tip functionality - show tip on mouse over
        thisItem.on('mousemove', function () {
            if (thisItem.attrs.firstDrag) {
                showToolTip(thisItem.attrs.label)
                tooltipLayer.draw();
            }

        });
        thisItem.on('mouseout', function () {
            if (thisItem.attrs.firstDrag) {
                tooltip.hide();
                tooltipLayer.draw();
                clearTimeout(timer1);
            }
        });
    }

    // create item
    function createItem(myX, myY, myZ, myWidth, myHeight, myFile, myItem, groupType, myLarge, myWidth2, myHeight2, myLabel) {
        var hb = 20;
        var thisItem = new Kinetic.Image({
            image: myItem,
            x: 60,
            y: myY,
            z: myZ,
            origX: 60,
            origY: myY,
            large: myLarge,
            label: myLabel,
            width: myWidth,
            height: myHeight,
            width2: myWidth2,
            height2: myHeight2,
            src: myFile,
            name: groupType,
            id: 'myObject' + objectCounter,

            offset: [myWidth / 2, myHeight / 2],
            firstDrag: true,
            dragOnTop: false,
            homeLayer: artLayer,
            opacity: 1,
            angle: 0,
            draggable: true,
            drawHitFunc: function (canvas) {
                var context = canvas.getContext();
                context.beginPath();
                context.moveTo(-hb, -hb);
                context.lineTo(this.getWidth() + hb, -hb);
                context.lineTo(this.getWidth() + hb, this.getHeight() + hb);
                context.lineTo(-hb, this.getHeight() + hb);
                context.closePath();
                canvas.fillStroke(this);
            }

        });
        return thisItem;
    }

    /*
     * Create main toolbar
     */
    function drawToolbar() {
        var bar = new Kinetic.Rect({
            // location
            x: 0,
            y: 0,
            // dimensions
            width: 450,
            height: 58,

            // gradient

            fillLinearGradientStartPoint: [0, 0],
            fillLinearGradientEndPoint: [0, 125],
            fillLinearGradientColorStops: [0, '#dedede', 1, 'grey'],

            strokeWidth: 1,
            cornerRadius: 5,
            name: 'toolbar'


        });
        toolbarGroup.add(bar);
        toolbarGroup.on('mousedown touchstart', function () {

            boardLayer.draw();
        });

        for (var i = 0; i < toolbarButtons.length; i++) {
            // position button sprite
            var btnX = bar.getX() + 20 + 60 * i;
            var btnY = bar.getY() + 4

            // draw button sprite

            drawToolbutton(bar, btnX, btnY, i);
        }

    }
    // add the toolbar to the stage


    /* shows the tool tip with a message corresponding to the button it is on */
    function showToolTip(tip) {

        var mousePos = stage.getMousePosition();
        tooltip.setPosition(mousePos.x + 5, mousePos.y + 5);
        tooltiptext.setText(tip);

        var tipWidth = tooltiptext.getWidth();
        tooltiprect.setWidth(tipWidth);

        tooltipLayer.draw();
    }

    function cursorStyle(obj) {

        obj.on('mouseover', function () {
            document.body.style.cursor = 'pointer';
        });

        obj.on('mouseout', function () {
            document.body.style.cursor = 'default';
        });

    }

    // add blank classroom map. 
    function drawClassroom(myWidth, myHeight) {



        var map = new Kinetic.Rect({
            x: leftEdge,
            y: topEdge,
            width: myWidth,
            height: myHeight,
            fill: startingFills[4],
            strokeWidth: 2,
            opacity: 1,
            yPos: 0,
            xPos: 0,
            yDiff: 0,
            xDiff: 0,
            name: 'classroom',
            id: 'wall4'
        });
        boardGroup.add(map);



        mapBehavior(boardGroup);

        makeWalls(leftEdge, topEdge, myWidth, myHeight);

        boardLayer.add(boardGroup);

        // alright, change myHeight to maxHeight, whatever that is; should be global
        drawGrid(myWidth, myHeight, 6, 8);



    }


    function makeWalls(leftEdge, topEdge, myWidth, myHeight) {

        // distance from ceiling to floor
        var wallVert = 65;
        var wallHoriz = 55;

        // floor corners
        var floorT = topEdge + wallVert;
        var floorR = leftEdge + myWidth - wallHoriz;
        var floorL = leftEdge + wallHoriz;
        var floorB = topEdge + myHeight - wallVert;
        var rightEdge = leftEdge + myWidth;
        var botEdge = topEdge + myHeight;


        /// point arrays
        var wallX = [];
        var wallY = [];

        // top wall points
        wallX[0] = [leftEdge, rightEdge, floorR, floorL];

        wallY[0] = [topEdge, topEdge, floorT, floorT];

        // right wall points
        wallX[1] = [rightEdge, rightEdge, floorR, floorR];

        wallY[1] = [topEdge, botEdge, floorB, floorT];

        // bottom wall points
        wallX[2] = [rightEdge, leftEdge, floorL, floorR];

        wallY[2] = [botEdge, botEdge, floorB, floorB];

        // left wall points
        wallX[3] = [leftEdge, floorL, floorL, leftEdge];

        wallY[3] = [topEdge, floorT, floorB, botEdge];





        for (var i = 0; i < 4; i++) {
            var x1, y1, x2, y2, x3, y3, x4, y4;

            x1 = wallX[i][0];
            y1 = wallY[i][0];
            x2 = wallX[i][1];
            y2 = wallY[i][1];
            x3 = wallX[i][2];
            y3 = wallY[i][2];
            x4 = wallX[i][3];
            y4 = wallY[i][3];

            drawWall(x1, y1, x2, y2, x3, y3, x4, y4, i);
        }
    }

    function mapBehavior(myWalls) {

        myWalls.on('mousedown touchstart', function () {

            var currentPos = trackTouch();
            x1 = currentPos.x;
            y1 = currentPos.y;

        });
        myWalls.on('mousemove', function () {
            if (isDown && currentTarget) {
                incrementPos();

                findDirection();
            }
        });

        myWalls.on('touchmove', function () {
            if (currentTarget) {
                incrementPos();
                findDirection();
            }
        });
    }

    function drawVertLine(topEdge, horizPos, botEdge, counter) {
        var gridLine = drawGridLine(horizPos, topEdge, horizPos, botEdge, 'vert', counter);
        return gridLine;
    }

    function drawHorizLine(leftEdge, vertPos, rightEdge, counter) {
        var gridLine = drawGridLine(leftEdge, vertPos, rightEdge, vertPos, 'horiz', counter);
        return gridLine;
    }

    // draw grid line
    function drawGridLine(x1, y1, x2, y2, type, counter) {
        var gridLine = new Kinetic.Line({
            points: [x1, y1, x2, y2],
            stroke: '#036',
            strokeWidth: 2,
            lineCap: 'square',
            opacity: 0.4,
            id: type + '-' + counter
        });
        gridGroup.add(gridLine);

        return gridLine;
    }
    // resizes the gridLine
    function resizeGridLine(x1, y1, x2, y2, gridLine) {
        gridLine.setPoints([x1, y1, x2, y2]);
        boardLayer.draw();
    }
    // tests to see if we should hide a gridLine. 
    function maskTest(myWidth, myHeight, gridLine, type) {
        var myPoints = gridLine.getPoints();

        if ((myPoints[1].x > myWidth && type == 'vert') || (myPoints[1].y > myHeight && type == 'horiz')) {

            gridLine.setVisible(false);
            boardLayer.draw();
        } else {
            gridLine.setVisible(true);
            boardLayer.draw();
        }
    }

    function resizeGridVert(myWidth, myHeight) {

        // we'll need the bottom edge for resizing vertical lines. 
        var botEdge = topEdge + myHeight;

        // we need the bottom edge for the mask test
        var rightEdge = leftEdge + myWidth;

        for (var i = 0; i < horizLines; i++) {
            // should gridLine be hiddden?
            var gridLine = stage.get("#horiz-" + i)[0];

            // test to see if we should mask it. 
            maskTest(rightEdge, botEdge, gridLine, 'horiz');

        }
        for (var j = 0; j < vertLines; j++) {
            // set the horizontal position of this vertical line, according to the interval.  
            var horizPos = leftEdge + vertInterval * j;

            // get the appropriate grid line
            var gridLine = stage.get("#vert-" + j)[0];

            // resize it!
            resizeGridLine(horizPos, topEdge, horizPos, botEdge, gridLine);

        }
    }

    function resizeGridHoriz(myWidth, myHeight) {
        // we'll need the right edge for resizing the horizontal lines.
        var rightEdge = leftEdge + myWidth;

        // we'll need to get the bottom edge for the mask test. 
        var botEdge = topEdge + myHeight;

        for (var i = 0; i < horizLines; i++) {
            // resize; change the right point of this gridLine to conform to the new width
            var vertPos = topEdge + horizInterval * i;

            // grab the grid line
            var gridLine = stage.get("#horiz-" + i)[0];

            // resize it!
            resizeGridLine(leftEdge, vertPos, rightEdge, vertPos, gridLine);
        }

        for (var j = 0; j < vertLines; j++) {
            // grab the gridLine
            var gridLine = stage.get("#vert-" + j)[0];

            // test to see if we should mask it. 
            maskTest(rightEdge, botEdge, gridLine, 'vert');
        }
    }

    function drawGrid(myWidth, myHeight) {
        // myHeight is not the height of the map, but the maximum height. 


        var rightEdge = leftEdge + myWidth;

        var botEdge = topEdge + myHeight;

        for (var i = 0; i < horizLines; i++) {
            // set vertical position based on which line it is and space between lines
            var vertPos = topEdge + i * horizInterval;

            // draw grid line and get the object
            var gridLine = drawHorizLine(leftEdge, vertPos, rightEdge, i);

            // test to see if we should mask it
            maskTest(rightEdge, botEdge, gridLine, 'horiz');

        }

        for (var j = 0; j < vertLines; j++) {
            var horizPos = leftEdge + j * vertInterval;

            // draw grid line and get the object
            var gridLine = drawVertLine(topEdge, horizPos, botEdge, j);

            // test to see if we should hide it
            maskTest(rightEdge, botEdge, gridLine, 'vert');
        }
        boardLayer.add(gridGroup);


        gridGroup.hide();
    }
    /*
     *  RESIZING FUNCTIONS
     */

    function incrementPos() {
        var currentPos = trackTouch();


        x2 = currentPos.x;
        y2 = currentPos.y;

        moveCounter++;
    }


    function findDirection() {
        // mouse / touch position - object position
        var diffYPos = y2 - currentTarget.getY();
        var diffXPos = x2 - currentTarget.getX();

        if (moveCounter >= 3) {
            moveCounter = 0;
            var direction;

            // if swipe to right above or swipe to left below
            if (y2 > y1) {
                direction = -0.025;
            } else {
                direction = 0.025;
            }


            resizeObject(direction);

            // reset x1 & y1 once every 20 times.
            x1 = x2;
            y1 = y2;
        }
    }

    function trackTouch() {

        var touchPos = stage.getTouchPosition();

        var mousePos = stage.getMousePosition();

        if (touchPos != undefined) return touchPos;

        else if (mousePos) return mousePos;

    }

    function resizeObject(direction) {

        var frameCount = 0;
        var myLayer = currentTarget.attrs.homeLayer;
        var anim = new Kinetic.Animation(function (frame) {

            frameCount++;



            if (frameCount >= 10) {
                anim.stop();
                return 0;
            }

            var scaleX = currentTarget.getScale().x;
            var scaleY = currentTarget.getScale().y;

            if ((direction > 0 && currentTarget.getScale().x < 3) || (direction < 0 && currentTarget.getScale().x > 0.3)) {
                currentTarget.setScale(scaleX + direction, scaleY + direction);
            }

        }, myLayer);

        anim.start();

    }

    
    function createText(myText) {
        var myText = $("#enter_text").val();

        var newText = new Kinetic.Text({

            x: stage.getWidth() / 2,
            y: stage.getHeight() / 2,
            text: myText,
            fontSize: 24,
            fontFamily: 'Calibri',
            fill: fontColor,
            id: 'myObject' + objectCounter,
            align: 'center',
            dragOnTop: false,
            firstDrag: false,
            draggable: true,
            opacity: 1,
            angle: 0,
            homeLayer: textLayer

        });

        addText(newText);
    }

    function createTextBox(myText) {
        var myText = $("#enter_text").val();

        var textBox = new Kinetic.Group({
            x: stage.getWidth() / 2,
            y: stage.getHeight() / 2,
            color: textBgColor,
            id: 'myObject' + objectCounter,
            draggable: true,
            firstDrag: false,
            dragOnTop: false,
            opacity: 1,
            rotating: false,
            angle: 0,
            homeLayer: textLayer
        });


        var newText = new Kinetic.Text({

            text: myText,
            fontSize: 24,
            fontFamily: 'Calibri',
            fill: fontColor,
            height: 'auto',
            width: 'auto',
            align: 'center',
            fontStyle: 'normal',


        });

        newText.setOffset(newText.getWidth() / 2, newText.getHeight() / 2);

        var boxHeight = newText.getHeight() + 20;
        var boxWidth = newText.getWidth() + 20;

        var newRect = new Kinetic.Rect({
            stroke: '#555',
            strokeWidth: 2,
            width: boxWidth,
            height: boxHeight,

            fill: textBgColor,
            cornerRadius: 10

        });

        newRect.setOffset(newRect.getWidth() / 2, newRect.getHeight() / 2);

        textBox.add(newRect);
        textBox.add(newText);
        addText(textBox);

    }

    // adds regular text without a background. 
    function addText(newText) {
        textLayer.add(newText);

        objectCounter++;

        cursorStyle(newText);

        pushObject(newText.attrs.id);

        var offY = newText.getHeight() / 2;

        var offX = newText.getWidth() / 2;

        newText.setOffset(offX, offY);

        textLayer.draw();

        newText.on('tap click', function () {

            checkMode(newText);
        });

        cursorStyle(newText);
    }
    

    function drawWall(x1, y1, x2, y2, x3, y3, x4, y4, i) {
        var Wall = new Kinetic.Polygon({

            points: [x1, y1, x2, y2, x3, y3, x4, y4],
            fill: startingFills[i],
            stroke: 'black',
            id: 'wall' + i,
            name: 'myWall',

            strokeWidth: 2
        });

        boardGroup.add(Wall);
        boardLayer.draw();
    }

    /*
     * polygon CODE
     */

    function findEdges() {
        var myWall = stage.get('#wall4')[0];

        var myWidth = myWall.attrs.width;
        var myHeight = myWall.attrs.height;

        var botEdge = topEdge + myHeight;


        var rightEdge = leftEdge + myWidth;

        return [rightEdge, botEdge];
    }

    function polyPoints(constant, sideLength, numSides, centerX, centerY, hyp) {

        constant = parseFloat(constant);
        // //// // // // // console.log("constant: " + constant);
        var angleDiff = (Math.PI * 2) / numSides;

        //swap in "sides" for 3

        var myPoints = [];

        for (var i = 0; i < numSides; i++) {
            var myAngle = constant + angleDiff * i;


            var xCoord = centerX + Math.cos(myAngle) * hyp;

            var yCoord = centerY + Math.sin(myAngle) * hyp;

            myPoints.push(xCoord);

            myPoints.push(yCoord);
        }

        return (myPoints);
    }

    function rectPoints(myWidth, myHeight, centerX, centerY) {
        myWidth = parseInt(myWidth);
        myHeight = parseInt(myHeight);
        centerX = parseInt(centerX);
        centerY = parseInt(centerY);

        var points = [
        centerX + myWidth / 2,
        centerY - myHeight / 2,

        centerX - myWidth / 2,
        centerY - myHeight / 2,

        centerX - myWidth / 2,
        centerY + myHeight / 2,

        centerX + myWidth / 2,
        centerY + myHeight / 2

        ];

        // //// // // // // console.log("points: " + points);
        return points;
    }
	
	
	 function addCircle(fill, stroke, type) {

        var rightEdge = findEdges()[0];

        var botEdge = findEdges()[1];

        var centerX = (rightEdge - leftEdge) / 2;

        var centerY = (botEdge - topEdge) / 2;

        var radius = parseInt($("#radius1").val());

     	

        var circle = buildCircle(artLayer,
        radius,
        stroke,
        fill,
        type,
        centerX,
        centerY) // to do 

		// set behavior of circle
        circleBehavior(objectCounter);

        // so that anchor points are on top. 
        //circle.moveToBottom();

        stage.draw();

        objectCounter++;
    }

    function addRectangle(fill, stroke, type) {

        var rightEdge = findEdges()[0];

        var botEdge = findEdges()[1];

        var centerX = (rightEdge - leftEdge) / 2;

        var centerY = (botEdge - topEdge) / 2;

        var myWidth = $("#width").val();

        var myHeight = $("#height").val();

        //var points = polyPoints(Math.PI/4, myWidth, 4, centerX, centerY, myHeight);
        var points = rectPoints(myWidth, myHeight, centerX, centerY);

        var rectangle = buildRectangle(artLayer,
        myWidth,
        myHeight,
        stroke,
        fill,
        points,
        type,
        centerX,
        centerY) // to do 

        shapeBehavior(objectCounter);

        // so that anchor points are on top. 
      //  rectangle.moveToBottom();

        stage.draw();

        objectCounter++;
    }

    function shapeColors(stroke, fill, shape) {
        if ($("#shape_fill").prop("checked")) {
            shape.setFill('#' + fill);
        }

        if ($("#shape_stroke").prop("checked") || !$("#shape_fill").prop("checked")) {
            shape.setStroke('#' + stroke);
            shape.setStrokeWidth(4);
        }
    }
    // sets the starting location of a shape
    function shapeStartLoc(shape, centerX, centerY) {
        shape.setX(centerX);
        shape.setY(centerY);



        shape.attrs.wasX = shape.getX();
        shape.attrs.wasY = shape.getY();

        shape.attrs.origY = shape.getY();
        shape.attrs.origX = shape.getX();
    }
    /*
     *    Building Shapes
     */
	 
	
	 function buildCircle(artLayer,
   	myRadius,
    stroke,
    fill,
    type,
    centerX,
    centerY) {
        // to do
        
       
      
        var circle = new Kinetic.Circle({

            dragOnTop: false,
            wasX: 0,
            wasY: 0,
            origX: 0,
            origY: 0,
            firstDrag: false,
            name: 'shape',
           	radius: myRadius,
            homeLayer: artLayer,
            opacity: 1,
            draggable: true,
            id: 'myShape' + objectCounter,
            number: objectCounter

        });
				
		// //// // // // // console.log('circle id: ' + circle.attrs.id);
		
		 setBasics(circle);
		 
		 pushObject(circle.attrs.id);

         pushShape(circle.attrs.id);

    	 shapeStartLoc(circle, centerX, centerY);

        // circle.setOffset(centerX, centerY);
       
         shapeColors(stroke, fill, circle);


         artLayer.add(circle);
		 
        var anchor = buildAnchor(artLayer, circle.getX() + myRadius, circle.getY(), "anchor" + objectCounter, 0, circle, type)

        artLayer.draw();
        return circle;
    }
	
    function buildRectangle(artLayer,
    myWidth,
    myHeight,
    stroke,
    fill,
    points,
    type,
    centerX,
    centerY) {
        // to do
        
        var rectangle = new Kinetic.Polygon({

            dragOnTop: false,
            wasX: 0,
            wasY: 0,
            origX: 0,
            origY: 0,
            firstDrag: false,
            name: 'shape',
            points: points,
            sides: 4,
            homeLayer: artLayer,
            opacity: 1,
            draggable: true,
            id: 'myShape' + objectCounter,
            number: objectCounter

        });

		 setBasics(rectangle);
		 
		 pushObject(rectangle.attrs.id);


        pushShape(rectangle.attrs.id);

        shapeStartLoc(rectangle, centerX, centerY);

        rectangle.setOffset(centerX, centerY);
        // stroke, fill, or both? 
        shapeColors(stroke, fill, rectangle);

		
    

        artLayer.add(rectangle);
		rectAnchors(points, rectangle, type)
        artLayer.draw();
        return rectangle;
    }
	function rectAnchors(points, rectangle, type)
	{
		for (e = 0; e < 4; e++) // only four sides to a rectangle 
        {
            var xIndex = e * 2;
            var yIndex = e * 2 + 1;
			
            buildAnchor(artLayer,
            points[xIndex],
            points[yIndex],
                "anchor" + objectCounter,
            e,
            rectangle,
            type)
        }
	}

    function addPolygon(fill, stroke, type) {


        var rightEdge = findEdges()[0];
        var botEdge = findEdges()[1];

        var sideLength = $("#side_length").val();

        var numSides = $("#num_sides").val();

        var hyp = sideLength / (Math.sin((2 * Math.PI) / numSides));

        var centerX = (rightEdge - leftEdge) / 2;

        var centerY = (botEdge - topEdge) / 2;

        var myPoints = polyPoints(0, sideLength, numSides, centerX, centerY, hyp);

        var polygon = buildPolygon(artLayer,
        myPoints,
            "polygon" + objectCounter,
        stroke,
        fill,
        numSides,
        hyp,
        centerX,
        centerY,
        type);

       // polygon.moveToBottom();

        shapeBehavior(objectCounter);
        stage.draw();
        objectCounter++;
    }

	function deleteAnchors(anchors)
	{
		 for (var l = 0; l < anchors.length; l++)
		 {
              anchors[l].destroy();
			  artLayer.draw();
         }
	}
    function anchorColors(myColor, visible) {
			
			// //// // // // // console.log("shape array length " + shapeArray.length);
			
        for (var k = 0; k < shapeArray.length; k++) {
            var myShape = stage.get(shapeArray[k])[0];
            var myNumber = myShape.attrs.number;

            var anchors = stage.get('.anchor' + myNumber);
            for (var l = 0; l < anchors.length; l++) {
				if (anchors[l])
				{
                if (visible)
					anchors[l].show();
                else 
					anchors[l].hide();
				
                anchors[l].setFill(myColor);
				}
			
            }
        }
        artLayer.draw();
    }

   

    function buildPolygon(artLayer, points, name, stroke, fill, numSides, radius, centerX, centerY, type) {

       // var polyGroup = makePolyGroup(); // add some layer choices eventually. 
   
        var polygon = new Kinetic.Polygon({

            dragOnTop: false,
            wasX: 0,
            wasY: 0,
            origX: 0,
            origY: 0,
            firstDrag: false,
            name: 'shape',
            points: points,
            sides: numSides,
            homeLayer: artLayer,
            opacity: 1,
            //drawHitFunc: function (context) {[points]},
            draggable: true,
            id: 'myShape' + objectCounter,
            number: objectCounter

        });
			
			
			// // // // console.log("myID: " + polygon.attrs.id);
         setBasics(polygon);
        pushObject(polygon.attrs.id);
		
		// //// // // // // console.log('polygon id: ' + polygon.attrs.id);
        // push shape into array. 
        pushShape(polygon.attrs.id);

        shapeStartLoc(polygon, centerX, centerY);

        polygon.setOffset(centerX, centerY);

        shapeColors(stroke, fill, polygon);

	    artLayer.add(polygon);
        for (e = 0; e < numSides; e++) //let's say it's 5 sides, so 10 points. 
        {
            var xIndex = e * 2;
            var yIndex = e * 2 + 1;
            buildAnchor(artLayer,
            points[xIndex],
            points[yIndex],
                "anchor" + objectCounter,
            e,
            polygon,
            type);
        }

  
   
        artLayer.draw();
        return polygon;
    }


    /*
     *  sets angles of anchor points. 
     */
    function storeAllAngles(anchor) {

        var anchors = stage.get('.' + anchor.attrs.name);

        for (var i = 0; i < anchors.length; i++) {
            anchors[i].attrs.angle1 = findAngle(anchors[i]);
            anchors[i].attrs.angle2 = findAngle(anchors[i]);

        }
    }
    // stores coordinates of anchor points. 
    function storeAllCoords(anchor) {
        var anchors = stage.get('.' + anchor.attrs.name);
        for (var i = 0; i < anchors.length; i++) {
            storeCoords(anchors[i]);

        }
    }

    function buildAnchor(layer,
    x, y,
    name,
    e,
    parentShape,
    type) {

        var cx = parentShape.getX();
        var cy = parentShape.getY();
        hdiff = difference(x, cx);
        vdiff = difference(y, cy);

        var iAngle = tangent(hdiff, vdiff);

        var anchor = new Kinetic.Circle({
            x: x,
            y: y,
            diff: 0,
			dragOnTop: false,
            myX: x,
            myY: y,
            angle1: 0,
            angle2: 0,
            polyType: type,
            radius: 12,
            stroke: "#666",
            fill: "#ddd",
            strokeWidth: 2,
            draggable: true,
            id: name + '-' + e,
			corner: e,
            name: name,
            rotating: false,
            number: objectCounter
        });



        // add hover styling
        anchor.on("mouseover", function () {
            document.body.style.cursor = "pointer";
            this.setStrokeWidth(4);
            artLayer.draw();
        });
        anchor.on("mouseout", function () {
            document.body.style.cursor = "default";
            this.setStrokeWidth(2);
            artLayer.draw();
        });
			
	
	
        anchor.on('mouseup touchend dragend', function () {
            storeAllCoords(anchor);
            storeAllAngles(anchor);
		
            anchor.attrs.angle1 = parseFloat(findAngle(anchor));
        });


        // set behavior on drag - polygon should resize
        anchor.on('dragmove touchmove', function () {
		
			// // // // console.log("dragging anchor");
	
			if (toolMode == 'rotate' && this.attrs.polyType != 'circle')
				spinAnchors(anchor, anchor.attrs.number);
            else if (anchor.attrs.polyType == 'rect')
			{
				resizeRect(anchor, anchor.attrs.number, anchor.attrs.corner);
				changePolygon(anchor.attrs.number);
			}
			else if (anchor.attrs.polyType == 'circle')
			{
				changeRadius(anchor.attrs.number);
			}
			else 
				changePolygon(anchor.attrs.number);
					
			
          

        });

       anchor.on('dragstart', function () {

            var myShape = stage.get('#myShape' + anchor.attrs.number)[0];
          

            if (toolMode == 'rotate' 
			&& anchor.attrs.polyType !='circle') 
			{
				var radius = findRadius(myShape, anchor);
                rotateDrag(this, radius, myShape);
            } 
			else  // not rotate
			{
                if (this.attrs.polyType == 'irreg' || this.attrs.polyType == 'rect' || this.attrs.polyType == 'circle')
    
                {
                    normalDrag(this);
	
                }
				else
				{
					// for regular polygons we can only drag along the line between anchor and center
                    var cx = myShape.getX();
                    var cy = myShape.getY();
                    var posX = parseFloat(anchor.attrs.myX);
                    var posY = parseFloat(anchor.attrs.myY);

                    //$('instructions').text('center: ' + cx + ',' + cy);
                  

                    var m = getSlope(posX, posY, cx, cy, anchor);
                    var b = getYInt(m, posX, posY);
                    //drawLine(cx, cy, posX, posY, 'red');
                    storeAllCoords(anchor);
                    fixedDrag(this, m, b, radius);
                }
            }
        });

        artLayer.add(anchor);

        anchor.hide(); 
        artLayer.draw();
		// //// // // // // console.log("anchor id/name: " + anchor.attrs.id + "/" + anchor.attrs.name);
        storeAllCoords(anchor);
			
        window.setTimeout(function () {

            storeAllCoords(anchor);
            storeAllAngles(anchor);

        }, 500);
	


			return anchor;
    }
	function changeRadius(number)
	{
		var myShape = stage.get('#myShape' + number)[0];
		var anchors = stage.get('.anchor' + number);
		var anchor = anchors[0];
		var sx = myShape.getX();
		var sy = myShape.getY();
		
		var ax = anchor.getX();
		var ay = anchor.getY();
		
		var myRadius = Math.sqrt(Math.pow(ax - sx, 2) + Math.pow(ay - sy, 2));
		
		myShape.setRadius(myRadius); 
		artLayer.draw();
	}
	function resizeRect(anchor, number, corner)
	{
	
		normalDrag(anchor);

		var nextAnchor;
		var prevAnchor;
		var diagAnchor;
				
		 var myShape = stage.get('#myShape' + number)[0];
		 var anchors = stage.get('.anchor' + number);

         for (var l = 0; l < anchors.length; l++)
		 {
			    var n = (corner-l)
				// find anchors ahead (ccw)
			    if (n == -1 || n == 3)
					nextAnchor = anchors[l];
	
				else if (n ==1 || n == -3)
					prevAnchor = anchors[l];
				
		
				else if(Math.abs(n) == 2)
					diagAnchor = anchors[l];		
			
		 }
				alignCorners(anchor, prevAnchor, nextAnchor, diagAnchor); 
				 alignCorners(anchor, nextAnchor, prevAnchor, diagAnchor);
				  
		
	}
	function alignCorners(anchor, coAnchor, refAnchor, diagAnchor)
	{
		// current cooordinates for current anchor
		var currentX  = anchor.getX();
		var currentY = anchor.getY();
				
		// old coordinates for current anchor
		var oldX = parseFloat(anchor.attrs.myX);
		var oldY = parseFloat(anchor.attrs.myY);
		
		// moving anchor
		var coX = parseFloat(coAnchor.attrs.myX);
		var coY = parseFloat(coAnchor.attrs.myY); 
		
		// reference anchor
		var refX = parseFloat(refAnchor.getX());
		var refY = parseFloat(refAnchor.getY()); 
		
		// anchor diagonally across from curent anchor
		var diagX = parseFloat(diagAnchor.attrs.myX);
		var diagY = parseFloat(diagAnchor.attrs.myY); 
		
		var m2 = objectSlope (anchor, coAnchor);	
		var m1 = getSlope(oldX, oldY, coX, coY, anchor);
	 
	 //	drawLine(oldX, oldY, refX, refY, 'blue');
		if (m1!=m2)
	     {
			// compare the *current* distance between anchor and ref with old distance between co and diagonal
			
			// find distance between current anchor and previous one
			var newDist = Math.sqrt(Math.pow(currentX - refX, 2) + Math.pow(currentY - refY, 2));
					  
			// find distance between next anchor and diagonal one
           	var oldDist = Math.sqrt(Math.pow(coX - diagX, 2) + Math.pow(coY - diagY, 2));
				  
		// the scale is the multiplier that you use to  alter the existing distance betwee the neighboring points. 
			var scale = newDist/oldDist;

				if (scale != 1)
				{
           			var newX =  Math.round((coX - diagX) * scale + diagX);
            		var newY = Math.round((coY - diagY) * scale + diagY);
				
					coAnchor.setX(newX);
					coAnchor.setY(newY);
        
					  	
					artLayer.draw();
			}
		}
				  
				

	}
  

    function storeCoords(anchor) {
        anchor.attrs.myX = anchor.getX();
        anchor.attrs.myY = anchor.getY();
    }

    /*
     *  used to find distance between triangle center and a given anchor. 
     */
    function findRadius(myShape, myAnchor) {
        var radius = 0;
        if (myAnchor) {

            var cx = myShape.getX();

            var cy = myShape.getY();

            var thisX = myAnchor.getPosition().x;

            var thisY = myAnchor.getPosition().y;

            var hdist = Math.round(thisX - cx);

            var vdist = Math.round(cy - thisY);

            radius = Math.sqrt(Math.pow(hdist, 2) + Math.pow(vdist, 2));

        }
        return radius;


    }
    /*
     *  Finds teh angle of an anchor. 
     */
    function difference(p1, p2) {
        var diff = Math.round(p1 - p2);
        return diff;
    }


    function findAngle(thisAnchor) {
        var myAngle = 0;

        if (thisAnchor) {
            var myShape = stage.get('#myShape' + thisAnchor.attrs.number)[0];


            var cx = myShape.getX(); //myCenter[0];

            var cy = myShape.getY(); //myCenter[1];

            var thisX = thisAnchor.attrs.myX; // + myShape.getX() - myShape.getOffset().x;

            var thisY = thisAnchor.attrs.myY; // + myShape.getY() - myShape.getOffset().y;

            var hdist = difference(thisX, cx);

            var vdist = difference(thisY, cy);


            myAngle = tangent(vdist, hdist);

        }
        return myAngle;


    }

    function tangent(vdist, hdist) {
        var myAngle = parseFloat(Math.atan(vdist / hdist));

        // 0 to 90 degres
        if (hdist >= 0 && vdist < 0) myAngle = -1 * myAngle;

        // 91 t0 180 degrees
        else if (hdist < 0 && vdist <= 0) myAngle = Math.PI - myAngle;

        // 180 to 270 degrees
        else if (hdist < 0 && vdist > 0) myAngle = Math.PI - myAngle

        // 269 to 360 degrees
        else if (hdist >= 0 && vdist >= 0) myAngle = 2 * Math.PI - myAngle;

        var myDeg = (myAngle * (180 / Math.PI));

        return myAngle;
    }

    // radians to degrees
    function radDeg(rad) {
        deg = Math.round(rad * (180 / Math.PI));
        return deg;
    }

    function getSlope(x1, y1, x2, y2, anchor) {
        var m = (parseFloat(y2) - parseFloat(y1)) / (parseFloat(x2) - parseFloat(x1));
        if (Math.abs(m) > 100) {
            m = 0;
        }
		

        return m;
    }

    function getYInt(m, x, y) {
        var b = -1 * (parseFloat(m) * parseFloat(x) - parseFloat(y));
        //drawLine(x, y, 0, b, 'blue');
        return b;

    }

    function XtoY(m, b, x) {
        y = m * x + b
        return y;
    }
	function objectSlope(o1, o2, anchor)
	{
		var x1 = o1.getX() ;
	   var y1 = o1.getY() ;
	   var x2 = o2.getX() ;
	   var y2 = o2.getY() ;
	   
	 	getSlope(x1, y1, x2, y2, anchor);
	}
	function objectLine(o1, o2, myColor) 
	{
       var x1 = o1.getX() ;
	   var y1 = o1.getY() ;
	   var x2 = o2.getX() ;
	   var y2 = o2.getY() ;
	   
	   drawLine(x1, y1, x2, y2, myColor);
    }
    function drawLine(x1, y1, x2, y2, myColor) {
        var line = new Kinetic.Line({
            points: [x1, y1, x2, y2],
            stroke: myColor,
            strokeWidth: 5,
            lineCap: 'round',
            lineJoin: 'round'
        });
        artLayer.add(line);

        artLayer.draw();

        window.setTimeout(function () {

            line.destroy();
            artLayer.draw();

        }, 1000);
    }

    function fixedDrag(anchor, m, b, radius) {

        var myFloor = stage.get('#wall4')[0];


        anchor.setDragBoundFunc(function (pos) {

            storeCoords(anchor);

            var myShape = stage.get('#myShape' + anchor.attrs.number)[0];
            var cx = myShape.getX() ;
            var cy = myShape.getY() ;


            var rightEdge = leftEdge + myFloor.attrs.width;
            var botEdge = topEdge + myFloor.attrs.height;
            var myID = '#' + this.attrs.id;
            var thisWidth = getCurrentWidth(myID);
            var thisHeight = getCurrentHeight(myID);
            var newY = pos.y > botEdge - thisHeight / 2 ? botEdge - thisHeight / 2 : pos.y;
            var newX = pos.x < leftEdge + thisWidth / 2 ? leftEdge + thisWidth / 2 : pos.x;

            if (pos.x > rightEdge - thisWidth / 2) newX = rightEdge - thisWidth / 2;

            if (pos.y < topEdge + thisHeight / 2) newY = topEdge + thisHeight / 2;


            var lineY = XtoY(m, b, pos.x);

            newY = (lineY == pos.y) ? newY : lineY;

        
            syncAnchors(anchor, radius, newX, newY);

     

            return {
                x: newX,
                y: newY
            }
        });
    }

    function normalDrag(anchor) {
        var myFloor = stage.get('#wall4')[0];

        anchor.setDragBoundFunc(function (pos) {
            var rightEdge = leftEdge + myFloor.attrs.width;
            var botEdge = topEdge + myFloor.attrs.height;
            var myID = '#' + this.attrs.id;
            var thisWidth = getCurrentWidth(myID);
            var thisHeight = getCurrentHeight(myID);
            var newY = pos.y > botEdge - thisHeight / 2 ? botEdge - thisHeight / 2 : pos.y;
            var newX = pos.x < leftEdge + thisWidth / 2 ? leftEdge + thisWidth / 2 : pos.x;

            if (pos.x > rightEdge - thisWidth / 2) newX = rightEdge - thisWidth / 2;

            if (pos.y < topEdge + thisHeight / 2) newY = topEdge + thisHeight / 2;

            return {
                x: newX,
                y: newY
            }
        });
    }

    function rotateDrag(anchor, radius, myShape) {

        anchor.setDragBoundFunc(function (pos) {
            var x = myShape.getX() ;
            var y = myShape.getY() ;

            // distance formula ratio to get current distance from center
            var cDist = Math.sqrt(Math.pow(pos.x - x, 2) + Math.pow(pos.y - y, 2));
            var scale = radius / cDist;


            if (scale < 1 || scale > 1) return {
                y: Math.round((pos.y - y) * scale + y),
                x: Math.round((pos.x - x) * scale + x)
            };
            else return pos;
        });
    }

    function moveAnchor(anchor, radius, newX, newY) {
        var myShape = stage.get('#myShape' + anchor.attrs.number)[0];

        //storeAllCoords(anchor);

        var cx = myShape.getX();
        var cy = myShape.getY();

        var posX = parseFloat(anchor.attrs.myX);
        var posY = parseFloat(anchor.attrs.myY);
  
        var anchorDist = Math.sqrt(Math.pow(posX - cx, 2) + Math.pow(posY - cy, 2));

        var newDistance = Math.sqrt(Math.pow(newX - cx, 2) + Math.pow(newY - cy, 2));
        var scale = newDistance / anchorDist;

        //	drawLine(cx, cy, posX, posY, 'yellow');

        var currentX = (posX - cx) * scale + cx;
        var currentY = (posY - cy) * scale + cy;

        anchor.setX(currentX);
        anchor.setY(currentY);

        //drawLine(cx, cy, currentX, currentY, 'green');



        artLayer.draw();


    }
	// anchors move in sync with dragged anchor so that the polygon resizes while keeping its shape
    function syncAnchors(anchor, radius, newX, newY) {

        var myX = anchor.getX() ;
        var myY = anchor.getY() ;
        var anchors = stage.get('.' + anchor.attrs.name);

        for (var m = 0; m < anchors.length; m++) {
            var myAnchor = anchors[m];

            if (myAnchor != anchor && myAnchor) moveAnchor(myAnchor, radius, newX, newY);
            changePolygon(anchor.attrs.number);
        }


    }

    function spinAnchors(anchor, number) {
        var myShape = stage.get('#myShape' + anchor.attrs.number)[0];

		// // // console.log("spin anchor " + number);

        storeCoords(anchor);
        anchor.attrs.rotation = true;


        anchor.attrs.angle2 = (findAngle(anchor));

      
        var anchors = stage.get(".anchor" + number);

        var a2 = parseFloat(anchor.attrs.angle2);
        var a1 = parseFloat(anchor.attrs.angle1);


        var myDiff = parseFloat(a2 - a1);

        for (var p = 0; p < anchors.length; p++) {
            var myAnchor = stage.get('#anchor' + number + '-' + p)[0];

            if (myAnchor != anchor && myAnchor) 
			{
				// // // console.log("rotate anchor");
				rotateAnchor(myAnchor, myDiff, p, myShape);
			}


            anchor.attrs.angle1 = parseFloat(anchor.attrs.angle2);
			
			if (anchor.attrs.polyType == 'reg-image')
			{
				rotateImage(number, myDiff);
			}
			else
			{
            	changePolygon(number);
			}
        }

        anchor.rotating = false;

    }

    function rotateAnchor(myAnchor, myDiff, p, myShape) {

        var radius  = findRadius(myShape, myAnchor);
			// // console.log("radius: " + radius);
        //myAnchor.attrs.angle1 = parseFloat(findAngle(myAnchor));

        myAnchor.attrs.angle2 = parseFloat(myAnchor.attrs.angle1) + parseFloat(myDiff);

		// // console.log("angle2: " + myAnchor.attrs.angle2);
		// // console.log("angle1: " + myAnchor.attrs.angle1);
        //set max and mins for angle
        if (myAnchor.attrs.angle2 > 2 * Math.PI)
		{
			// console.log("angle is greater than 2 pi");
			myAnchor.attrs.angle2 -= 2 * Math.PI;
		}

        else if (myAnchor.attrs.angle2 < 0) 
		{
			// console.log("angle is less than zero");
			myAnchor.attrs.angle2 += 2 * Math.PI;
		}

        myAnchor.attrs.angle1 = parseFloat(myAnchor.attrs.angle2);

        var a2 = parseFloat(myAnchor.attrs.angle2);

        var a1 = parseFloat(myAnchor.attrs.angle1);

        var oldX = myAnchor.getX();
        var oldY = myAnchor.getY();
			
			// // console.log("old x/y: " + oldX + "," + oldY);
        var newX = Math.cos(-1 * a2) * radius

        var newY = Math.sin(-1 * a2) * radius;

        myAnchor.setX(newX + myShape.getX());

        myAnchor.setY(newY + myShape.getY());

        artLayer.draw();

    }

    function moveLabels(labels, polygon, anchors, i) {
        labels[i].setX(anchors[i].getX() + (polygon.getX() - polygon.attrs.wasX));
        labels[i].setY(anchors[i].getY() + (polygon.getY() - polygon.attrs.wasY));
        labels[i].setText(Math.round(findAngle(anchors[i]) * (180 / Math.PI)));
        artLayer.draw();
    }
	
	function circleBehavior(e) {
		
		var circle = stage.get("#myShape"+e)[0];
		// toggle anchor
		circle.on('dblclick dbltap', function () {
			
			  var anchor = stage.get("#anchor0-" + e);
			
			if (anchor.attrs.visible)
			{
				anchor.hide();
				artLayer.draw();
			}
			else
			{
				anchor.show();
				artLayer.draw();
			}
			
			
			});
			
		
		 circle.on('dragmove touchmove dragend touchstart touchmove touchend tap click', function () {
			 
            var anchor = stage.get("#anchor"+e+"-0")[0];
           		//storeCoords(anchor);

            // when polygon is dragged, anchors move with the polygon
            
                anchor.setX(anchor.attrs.myX + (circle.getX() - circle.attrs.wasX));
                anchor.setY(anchor.attrs.myY + (circle.getY() - circle.attrs.wasY));
                storeCoords(anchor);

      
            circle.attrs.wasX = circle.getX();
            circle.attrs.wasY = circle.getY();
		 });
	}
    function shapeBehavior(e) {

        // need to change this
        var polygon = stage.get("#myShape"+e)[0];

        polygon.on('dblclick dbltap', function () {

            var anchors = stage.get(".anchor" + e);

            if (anchors[0].attrs.visible) {
                for (var j = 0; j < anchors.length; j++) {
                    anchors[j].hide();
                    artLayer.draw();
                }
            } else {
                for (var k = 0; k < anchors.length; k++) {
                    anchors[k].show();
                    artLayer.draw();
                }
            }



        });



        polygon.on('dragstart dragmove dragend touchstart touchmove touchend tap click', function () {
            var anchors = stage.get(".anchor" + e);
            var labels = stage.get(".mylabel");
			
			// //// // // // // console.log("test coord: " + anchors[0].getY());
            // when polygon is dragged, anchors move with the polygon
            for (var i = 0; i < anchors.length; i++) {
                anchors[i].setX(anchors[i].getX() + (polygon.getX() - polygon.attrs.wasX));
                anchors[i].setY(anchors[i].getY() + (polygon.getY() - polygon.attrs.wasY));
                storeCoords(anchors[i]);
                if (labels[i]) {
                    moveLabels(labels, polygon, anchors, i);

                }



            }
            polygon.attrs.wasX = polygon.getX();
            polygon.attrs.wasY = polygon.getY();


         
        });
    }


    function changeCircle(i) {

        var myCircle = stage.get("#myShape" + i)[0];


        var anchors = stage.get(".anchor" + i);

        // var newPoints
		var newRadius = anchors[0].getX() - (myCircle.getX() - myCircle.attrs.origX);
     

        myCircle.setRadius(newRadius);


        stage.draw();
    }
	
	function resizePic(i)
	{
		var myImage = stage.get("#myShape" + i)[0]; // use myShape?

        var anchors = stage.get(".anchor" + i);
		
		var myWidth = anchors[1].getX() - anchors[2].getX();
		
		var getHEight = anchors[0].getY() - anchors[3].getY();
		
		myImage.setWidth(myWidth);
		
		myImage.setHeight(myHeight);
	}
    function changePolygon(i) {

		// // // // console.log("changePolygon");
        var polygon = stage.get("#myShape" + i)[0];


        var anchors = stage.get(".anchor" + i);

        // var newPoints

        var newPoints = [];
			
	
        for (j = 0; j < polygon.attrs.sides; j++) 
		{


            // delete the 'wasX/ wasY stuff if you add an offset. 
          newPoints.push(anchors[j].getX() - (polygon.getX() - polygon.attrs.origX));
           newPoints.push(anchors[j].getY() - (polygon.getY() - polygon.attrs.origY));
        }
			
		if (anchors[0].attrs.polyType == 'reg-image')
		{	
		   var myWidth = anchors[0].getX() - anchors[1].getX();
			var myHeight = anchors[3].getY() - anchors[0].getY(); 
			
			polygon.setWidth(myWidth);
			polygon.setHeight(myHeight);
			
			polygon.setOffset(myWidth/2, myHeight/2);

		}
		else
		{
			
         polygon.setPoints(newPoints);
		}


        //stage.draw();
    }


});
