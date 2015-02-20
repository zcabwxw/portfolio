// JavaScript Document

// pause | menu | scores | recal
init();

function init()
{
	var table = document.getElementById('highscores');
	
	attachHeaders(table);
	
	scoreData(table);
	
	
	window.setTimeout(function () {addListeners()}, 1000);

	
}

function addListeners()
{
	var menu = document.getElementById('scoremenu');
	
	var newGame =  document.getElementById('scorenew');
	
	var quit = document.getElementById('scorequit');
	
	// listener for new game
	
	newGame.addEventListener('touchstart', function (event)
	{
		window.location.href = 'http://birdleymedia.com/portfolio/Web/marble_game/game.html';
	});
	
	// listener for scores
	
	menu.addEventListener('touchstart', function (event)
	{
		window.location.href = 'http://birdleymedia.com/portfolio/Web/marble_game/main.html';
	});
	
	
	// listener for quit
	
	quit.addEventListener('touchstart', function (event)
	{
		window.location.href = 'http://birdleymedia.com';
	});
	
	

	
		newGame.addEventListener('mousedown', function (event)
	{
		window.location.href = 'http://birdleymedia.com/portfolio/Web/marble_game/game.html';
	});
	
	// listener for scores
	
	menu.addEventListener('mousedown', function (event)
	{
		window.location.href = 'http://birdleymedia.com/portfolio/Web/marble_game/main.html';
	});
	
	
	// listener for quit
	
	quit.addEventListener('mousedown', function (event)
	{
		window.location.href = 'http://birdleymedia.com';
	});
}
function attachHeaders(table)
{

	var headers = ['score','time','location'];
	
	addRow(headers, table)
}

// adds the score data
function scoreData(table)
{	
	for (var i = 0; i < 5; i++)
	{
		addDataRow(table, i);
	}
	
}
// adds a row to the table
function addRow(data, table)
{
	var myRow = table.appendChild(document.createElement('tr'));
	
	for (var i = 0; i < data.length; i++) addCell(myRow, data[i])

}
function addDataRow(table, index)
{
		
	
	var myScore = localStorage.getItem('scoreKey'+index);
	var myTime = localStorage.getItem('timeKey'+index);
	var myLoc = localStorage.getItem('locKey'+index);
	
	if (myScore>=0 && myScore != null)
	{
		console.log('here');
	var myRow = table.appendChild(document.createElement('tr'));
	addCell(myRow, myScore);
	addCell(myRow, myTime);
	addCell(myRow, myLoc);
	}
	
}
// adds a cell to a row
function addCell (row, content)
{
	console.log('content: ' + content);
	var cell = row.appendChild(document.createElement('td'));
	
	cell.appendChild(document.createTextNode(content));
}