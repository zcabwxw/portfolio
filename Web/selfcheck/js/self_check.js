/************************************************************************************
 *                                                                                  *
 *                          Art Sorting Self-Check                                  *
 *                          Nevin Katz, ETLO                                        *
 *                          Last Updated: February, 2015                            *
 *                                                                                  *
 *************************************************************************************/
(function($) {

    Drupal.behaviors.selfcheck = {
        attach: function(context, settings) {

            $('body').once('loadSelfcheck', function() {
                // Run the selfcheck to the elements only once.
                // is the ajax loaded?
                var ajaxLoaded = false;
                // initializes array of answers
                var answers = [];
                // array of the specific items that have been dropped into columns.  Used to check if user has tried to move all of them.
                var itemsDropped = [];
                // array that stores the correct answer. 
                var correctAns = [];
                // painting titles
                var captions = [];

                var ans = [];
                var tries = 0;
                var targets = [];
                var images = [];
                var i;
                var bp;
                var twolines = false;

                var colorIndex = 0;
                $.fn.doesExist = function() {
                    return jQuery(this).length > 0;
                };
                init();


                function init() {

                    i = Drupal.settings.self_check_app_num - 1;

                    bp = Drupal.settings.selfcheck.basepath;

                    $('.submit-cols').button();
                    $('#statpanel').css('width', '480').css('margin-top', '25px');

                    $.ajax({
                        type: "GET",
                        /*url: "../sites/default/modules/custom/selfcheck/xml/columns_images.xml",*/
                        url: bp + "selfcheck/xml/columns_images.xml",
                        dataType: "xml",
                        success: function(xml) {

                            var intro = $(xml).find("intro").text();
                            $('#intro').append('<p>' + intro + '<p>');
                            var myTitle = $(xml).find("title").text();
                            $('#title').text(myTitle);

                            $(xml).find('applet' + i).each(function() {
                                $(this).find("cols").each(function() {
                                    $(this).find("col").each(function() {
                                        var myCol = $(this).text();
                                        targets.push(myCol);
                                    });
                                });
                                $(this).find("items").each(function() {
                                    // get draggable items with correct / incorrect answers.  
                                    $(this).find("item").each(function() {

                                        var myImage = $(this).find("image").text();

                                        var myCaption = $(this).find("caption").text();

                                        images.push(myImage);
                                        answers.push(false);
                                        captions.push(myCaption);
                                    });
                                });


                                // set answer key
                                key = $(this).find("answer").text();
                                var last = key.length;

                                // parse answer key string and push each answer into an array
                                for (var i = 0; i < last; i++) {
                                    var number = key.substring(i, i + 1);
                                    var id = number;
                                    correctAns.push(id);
                                }
                                // rows, cols, stacking
                                populate();
                                ajaxLoaded = true;
                            });
                            // add setLayout code if we need to customize.
                        }
                    });

                    // populates screen with the art items
                    function populate() {
                        for (var i = 0; i < images.length; i++) addDragItem(i);

                        for (var j = 0; j < targets.length; j++) addTarget(j);
                        dropFunctionality();

                        $('#targets').css('position', 'absolute');
                    }

                    function showCorrect() {
                        for (var i = 0; i < correctAns.length; i++) addDragItem(correctAns[i]);
                        $('.draggable').css('position', 'relative').css('top', '185px').css('z-index', '100'); /*185 px*/
                    }

                    $(".submit-cols").click(function() {
                        $('.ui-dialog .ui-button').html('');
                        // get dimensions of top drag container
                        var dragConHeight = $('#draggables').css('height');
                        var dragConWidth = $('#draggables').css('width');

                        var maxTries = 2;
                        tries++;
                        var t = $('.target_container').length;

                        // declare the match as true by default
                        var match = true;

                        resp = 0;
                        $('#feedback').html('');

                        var n = $('.drag_image').length;
                        for (var m = 0; m < n; m++) {
                            if (!answers[m]) match = false;
                            resp++;
                        }
                        var accuracy;

                        // formulate response
                        if (match) {
                            accuracy = 'correct';
                            showFeedback();
                            // $('#training-viewer-activity').append("<div class='training-already-flagged'></div>");
                        } else if (itemsDropped.length < correctAns.length) {
                            tries--;
                            accuracy = 'incomplete';
                            $('#feedback').append("<p>Please drag each item into a target region.</p>");
                        }
                        // if max tries has been exceeded, show the correct answer. 
                        else if (tries > maxTries) {
                            var regionHeight = $('#draggables').css('height');
                            $('#training-viewer-activity').append("<div class='training-already-flagged'></div>");

                            accuracy = 'neutral';
                            var myHeight = $('#draggables').css('height');
                            removeAll(dragConWidth, dragConHeight);
                            $('#draggables').css('height', myHeight);

                            showCorrect();
                            $('#feedback').append("<p>You've completed three tries, so here is the correct response.</p>");
                        } else {
                            showFeedback();
                            accuracy = 'incorrect';
                        }
                        dialogStyle(accuracy);
                        $('#feedback').dialog('open');

                    });

                    function addPlaceholder() {
                        $('#draggables').append("<div class='draggable placeholder'></div>");
                    }

                    function addTarget(j) {

                            var myTarget = targets[j];
                            $('#targets').append("<div id = 'con" + j + "' class='target_container'></div>");
                            $('#con' + j).append("<div id='col" + j + "' class='snaptarget'></div><p>" + targets[j] + "</p>");
                        }
                        // set up dialog box
                    $("#feedback").dialog({
                        autoOpen: false,
                        width: 400,
                        listening: false,
                        resizable: false,
                        modal: true,
                        show: 'fade',
                        hide: 'fade',
                        draggable: true
                    });
                }

                // string to int
                function toInt(myString) {
                        var myInt;
                        myInt = parseInt(myString.substring(0, myString.length - 2));
                        return myInt;
                    }
                    // int to string
                function makeString(myInt) {
                    var myString;
                    myString = myInt.toString() + 'px';
                    return myString;
                }

                function showFeedback() {
                    var inc = [];
                    var cor = [];
                    var letters = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P'];

                    for (var i = 0; i < answers.length; i++) {

                        if (answers[i] == true)
                            cor.push(captions[i])
                        else
                            inc.push(captions[i])
                    }

                    var corString = '';
                    var incString = '';
                    var pc = parseInt(cor.length / images.length * 100)

                    if (cor.length == images.length) {
                        corString = 'All items are placed correctly!';
                        $('#feedback').append('<p>' + corString + '</p>');
                    } else if (cor.length > 0) {
                        corString = ansString(cor, 'placed correctly');
                        $('#feedback').append('<p>' + pc + '% correct.</p><p>' + corString + '</p>');

                        incString = ansString(inc, 'placed incorrectly');
                        $('#feedback').append('<p>' + incString + '</p>');
                    } else
                        $('#feedback').append('<p>No items are placed correctly.</p>');
                }

                function ansString(array, adjective) {
                    var myString = '';

                    if (array.length == 1) {
                        myString = '<em>' + array[0] + '</em>' + ' is ' + adjective + '.'
                        return myString;
                    } else if (array.length == 2) {
                        myString = '<em>' + array[0] + '</em>' + ' and ' + '<em>' + array[1] + '</em>' + ' are ' + adjective + '.'
                        return myString;
                    }
                    for (var j = 0; j < array.length; j++) {
                        if (j < array.length - 1)
                            myString += '<em>' + array[j] + '</em>' + ', '
                        else myString += 'and <em>' + array[j] + '</em> are ' + adjective + '.';
                    }
                    return myString;
                }

                function searchList(list, id) {
                    for (var i = 0; i < list.length; i++) {
                        if (id == list[i]) return true;
                    }
                    return false;
                }

                function extractNum(myString) {
                    var testNum = myString.substring(myString.length - 2, myString.length - 1);
                    var digits = 1;
                    if (!isNaN(testNum)) digits = 2;
                    var myNum = parseInt(myString.substring(myString.length - digits, myString.length));
                    return myNum;
                }

                function no_hover(obj) {
                    $(obj).parent().removeClass("container-hover");
                }

                function removeAll(dragConWidth, dragConHeight) {

                        $('.drag_container').each(function() {
                            $(this).remove();
                        });

                        $('#draggables').css('width', dragConWidth);
                        $('#draggables').css('height', dragConHeight);
                    }
                    // gets the url
                function getUrlVars() {
                    var vars = [],
                        hash;
                    var hashes = window.location.href.slice(window.location.href.indexOf('?') + 1).split('&');
                    for (var i = 0; i < hashes.length; i++) {
                        hash = hashes[i].split('=');
                        vars.push(hash[0]);
                        vars[hash[0]] = hash[1];
                    }
                    return vars;
                }

                function setImage(ic, imagePath) {
                    $(ic).css('background-image', 'url("' + imagePath + '")');
                    $(ic).css('backgroundPosition', '0px 0px');
                    $(ic).css('background-repeat', 'no-repeat');
                }

                function addIndent(str) {
                    console.log("add");
                    var tuple = str.split('/br/')
                    var strA = tuple[0];
                    var strB = tuple[1];
                    var spc = '<br/>';
                    for (var i = 0; i < 5; i++) spc = spc + '&#160';
                    var final = strA + spc + strB;
                    return final;
                }

                function isTwoLines(myText) {
                    var len = myText.length;
                    var maxlen = 20;
                    var isTwo = (len > maxlen) ? true : false;
                    return isTwo;
                }

                function correctPlace(id, dr, dragit) {
                    $(id).append(dragit);
                    $(dr).css('margin', '0px auto').css('float', 'none');
                }

                function addDragItem(i) {
                    var id = '#draggables';
                    // container that holds draggable           
                    var con = "<div id='con" + i + "'></div>";

                    // the draggable itself and its id
                    var dragit = "<div id='draggable" + i + "' class='draggable drag_image'></div>";
                    var dr = '#draggable' + i;

                    // set image path and assign it to a new image

                    var path = bp + 'selfcheck/images/thumbnails/';
                    var imagePath = path + images[i];
                    var myImage = new Image();
                    myImage.src = imagePath;

                    // shorten this
                    $(id).append('<div id="dragcon' + i + '" class="drag_container"></div>');
                    $('#dragcon' + i).append(dragit);

                    // add actual image and contents.
                    setImage('#draggable' + i, imagePath);
                    dragFunctionality(i);
                }

                function dialogStyle(accuracy) {
                    $('#feedback').dialog().parent(".ui-dialog").unwrap();
                    $('#feedback').dialog().parent(".ui-dialog").css('z-index', '4999');
                    switch (accuracy) {
                        case "correct":
                            $('#feedback').dialog().parent(".ui-dialog").wrap("<div class='correct'></div>");
                            $('#feedback').dialog("option", "title", "CORRECT");
                            break;
                        case "incorrect":
                            $('#feedback').dialog("option", "title", "INCORRECT");
                            break;
                        case "neutral":
                            $('#feedback').dialog("option", "title", "THREE TRIES COMPLETE");
                        case "incomplete":
                            $('#feedback').dialog("option", "title", "INCOMPLETE");
                            break;
                    }
                    // open feedback box
                    $('#feedback').dialog("open");
                }

                function adjustSnap(ui, tolerance) {
                    var dragId = $(ui.draggable).attr('id');
                    $('#' + dragId).draggable('option', 'snapTolerance', tolerance);
                }

                function dropFunctionality() {
                    $('.target_container').droppable({

                        over: function(event, ui) {
                            $(this).addClass("container-hover");
                            adjustSnap(ui, 50);
                        },

                        out: function(event, ui) {
                            $(this).removeClass("container-hover");
                            adjustSnap(ui, 20);

                        },
                        drop: function(event, ui) {
                            $(this).removeClass("container-hover");
                            captureDrop($(this), ui);
                        }
                    });
                }

                function captureDrop(obj, ui) {
                    no_hover($(obj));
                    var dropId = $(obj).attr('id');
                    var dragId = $(ui.draggable).attr('id');
                    var dropNum = dropId.substring(dropId.length - 1, dropId.length);

                    if (searchList(itemsDropped, dragId) == false) itemsDropped.push(dragId);

                    var dragNum = extractNum(dragId);

                    // set the item's index in answers array as correct or incorrect. 

                    if (correctAns[dropNum] == dragNum)

                        answers[dragNum] = true;
                    else
                        answers[dragNum] = false;

                    // alert("answers: " + answers);
                }

                function dragFunctionality(count) {
                    var n = count + 1;
                    $(".draggable").draggable({
                        snap: ".snaptarget",
                        stack: ".drag_image",
                        snapMode: "inner",
                        snapTolerance: 30,
                        containment: $('#dragbounds'),
                        revert: false,
                        id: 1,
                        stop: function(event, ui) {
                            $(this).draggable('option', 'snapTolerance', 20);

                            $(this).removeClass('item-shadow'); /*.css('border','1px solid blue');*/
                        },
                        start: function(event, ui) {
                            var dragId = $(this).attr('id');
                            var dragNum = extractNum(dragId);
                            $(this).addClass('item-shadow'); /*.css('border','1px solid blue');*/

                            // since we are picking this one up, the answer has to be false for now. 
                            answers[dragNum] = false;
                        }
                    });
                }
            });
        }
    };
})(jQuery);