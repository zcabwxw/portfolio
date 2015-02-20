
<link rel="stylesheet" href="<?php print $basepath ?>selfcheck/css/cb.css" />
<script type="text/javascript" src="<?php print $basepath ?>selfcheck/js/self_check.js"></script>
<script type="text/javascript" src="<?php print $basepath ?>selfcheck/js/jquery.ui.touch-punch.min.js"></script>

<div id="feedback" title="Feedback"></div>
<div id="wrapper"> 
  <div id="submit-area"> 
  </div>
  <div id="problem">
    <div id="dragbounds">
      <div id="area" class="columns_area">
        <h1 id="title"></h1>
        <div id="intro"></div>
        <div id="draggables"> </div>
        <div id="targets"></div>
        <div class="clearboth"> </div>
            <div id="columns-statpanel">
        <button type="submit" name="submit_seq"  id="submit" class="submit-cols">SUBMIT ></button>
      </div>
      </div>
    </div>
  </div>
</div>