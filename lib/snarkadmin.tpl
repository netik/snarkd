<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
	  "http://www.w3.org/TR/html4/loose.dtd">
<HTML>
 <HEAD>
  <LINK REL="stylesheet" TYPE="text/css" HREF="//www.dnalounge.com/dnalounge.css?1">
  <TITLE>DNA Lounge: Sign Admin</TITLE>
<!-- %%HEAD_START%% -->
  <STYLE TYPE="text/css">
<!--
  textarea \{
   font-size: 10pt;
   line-height: 12pt;
   font-family: "Bitstream Vera Sans Mono", Menlo, "Courier New", Courier, monospace;
  \}
-->
</STYLE>
<!-- %%HEAD_END%% -->
  <SCRIPT TYPE="text/javascript"><!--
   var _gaq = _gaq || [];
   _gaq.push(['_setAccount', 'UA-19982885-1']);
   _gaq.push(['_setDomainName', '.dnalounge.com']);
   _gaq.push(['_trackPageview']);
   (function() \{
     var s = document.getElementsByTagName('script')[0];

     var ga = document.createElement('script');
     ga.type = 'text/javascript'; ga.async = true;
     ga.src = 'https://ssl.google-analytics.com/ga.js';
     s.parentNode.insertBefore(ga, s);

     ga = document.createElement('script');
     ga.type = 'text/javascript'; ga.async = true;
     ga.src = 'https://apis.google.com/js/plusone.js';
     s.parentNode.insertBefore(ga, s);
   \})();
   //-->
  </SCRIPT>
  <META NAME="geo.position" CONTENT="37.771007;-122.412694">
  <META NAME="viewport" CONTENT="width=device-width">
  <LINK REL="shortcut icon" HREF="/favicon.ico" TYPE="image/x-icon">
  <LINK REL="top"   HREF="//www.dnalounge.com/">
  <LINK REL="up"    HREF="../">
  <LINK REL="menubase" HREF="//www.dnalounge.com/">
 </HEAD>
 <BODY>
  <DIV CLASS="page">
   <DIV CLASS="top">
<!-- %%MENU_START%% -->
   <DIV CLASS="masthead"><A HREF="//www.dnalounge.com/"><IMG SRC="//www.dnalounge.com/logo.gif"></A></DIV>
   <UL CLASS="menu" ID="menu1"><LI>
    <A HREF="//www.dnalounge.com/./">Home</A>
    </LI><LI><A HREF="//www.dnalounge.com/calendar/latest.html">Calendar</A>
    </LI><LI><A HREF="//www.dnalounge.com/directions/">Directions</A>
    </LI><LI><A HREF="//www.dnalounge.com/tickets/">Tickets</A>
    </LI><LI><A HREF="//www.dnalounge.com/webcast/">Webcasts</A>
    </LI><LI><A HREF="//www.dnalounge.com/contact/">Contact</A>
   </LI></UL>
<!-- %%MENU_END%% -->
   </DIV>
   <DIV CLASS="bottom">
<!-- %%BOTTOM_START%% -->
<!-- message form -->
<INPUT TYPE=HIDDEN NAME=msgid VALUE={$msgid}>
<div class="gwbox">Snark-a-Tron</div>
<center>{$status}</center>
<P>
 Jump to:
 	 <a href="logview.cgi">Message Log</a> |
	 <a href="../dj/djadd.cgi">DJ Song/Title Entry</a> |
	 <a href="../dj/djsched.cgi">DJ Schedule Entry</a> |
	 <a href="../promoter/">Promoter Page</a> |
	 <a href="../">Public Message Entry</a> 
</p>

{$queuehdr}
{$queue}
<input type=submit name=Update value=Update>
<div id="header">
{$addtitle}
</div>
<table>
<tr>
<td width=75 id='desc' valign=top>
Message<br>
(Required)
</td>
<td>
<table border=0 cellpadding=0 cellspacing=0><tr><td nowrap valign=top>
<TEXTAREA ROWS=5 COLS=32 WRAP=SOFT NAME="newmsg">
{$newmsg}</TEXTAREA>
</td>
<td width=20 nowrap></td>
<td nowrap valign=top>
<div id=specials><font color=#aaaaaa>Message specials:</font>

<TABLE BORDER=0 CELLSPACING=0 CELLPADDING=0>
<TR>
  <td width=40 rowspan=3></td>
  <TD NOWRAP STYLE="color:F00">%%R&nbsp; Red</TD>
  <TD NOWRAP WIDTH=30></TD>
  <TD NOWRAP>%%X&nbsp; <SPAN STYLE="background:#0F0">&nbsp;&nbsp;</SPAN> &nbsp;(Box)</TD>
</TR>
<TR>
  <TD NOWRAP STYLE="color:0F0">%%G&nbsp; Green</TD>
  <TD></TD>
  <TD NOWRAP>%%B&nbsp; Blink</TD>
</TR>
<TR>
  <TD STYLE="color:FFF833">%%A&nbsp; Amber</TD>
  <TD></TD>
  <TD NOWRAP>%%E&nbsp; Blink off</TD>
</TR>
</TABLE>

</div>
</td>
</tr></table>

</td>
<tr>
<td id=desc width=75>External Cmd</td>
<td><input type=text name=extcmd value="{$extcmd}" size=80 maxlength=255><br>
<font color="#aaaaaa">If set, output of command overrides message.</a>
</td>

</tr>
</tr>
<TR><td id='desc' width=75>Enable? </td><td>{$enablehtml}</td></tr>
<TR><td id='desc' width=75>Dwell Time: </td><td><input type=text size=3 maxlen=3 name=dwell value={$dwell}> (seconds)</td></tr>
<TR><td id='desc' width=75>Priority: </td><td><input type=text size=3 maxlen=3 name=priority value={$priority}> (lower = higher priority)</td></tr>
<TR><td id='desc' valign=top width=75> Displayed: </td><td><input type=text size=10 maxlen=10 name=displayed value={$displayed}> (increments each time message is shown)</td></tr>
<TR><td id='desc' valign=top width=75> Max Views: </td><td><input type=text size=3 maxlen=3 name=cnt value={$cnt}> (0 = infinite)</td></tr>
<TR><td id='desc'>Justify: </td><td>{$justifygroup}</td><tr>
<TR><td id='desc'> Word Wrap: </td><td>{$wordwraphtml} </td></tr>
<TR><td id='desc'> Wipe? </td><td>{$wipehtml}</td></tr>

<TR>
	<td id='desc' valign=top>Days Shown</td>
	<TD>{$dayshtml}</TD>
</TR>

<TR>
	<td id='desc' valign=top>Hours Shown</td>
	<TD>{$timehtml}</TD>
</TR>

<TR>
	<td id='desc' valign=top>Expires After<br>0=never</td>
	<TD><input type=text name=destroyat value={$destroyat}> = 	 {
	    if ($destroyat == 0) { 
	        $datext = "Never Expire";
             } else { 
         	$datext = localtime($destroyat);
             }
         }

</TR>

<TR>
	<TD id='desc'>&nbsp;</TD>
	<Td><input type=submit name={$addbutton} Value={$addbutton}>
	</td>
</tr>
</table>
<div id="header">
Sign Settings and Message Defaults
</div>

<table>
<tr>
<td width=75 id='desc' valign=top>
Sign Mode
</td>
<td>
{$modegroup}
</td>
</tr>


<tr>
<td width=75 id='desc' valign=top>
Operating Hours
</td>
<td>
{$signtimehtml}<br>
These operating hours are in effect regardless of the sign mode setting.<br>
To disable the timer, set the operating time to 00:00-23:59
</td>
</tr>

<tr>
<td width=75 id='desc' valign=top>
Public Add Page
</td>
<td>
{$addpagegroup}
</td>
</tr>

<tr>
<td width=75 id='desc' valign=top>
SnarkFilter<BR>(Block dirty words)
</td>
<td>
{$snarkfiltercb}
</td>
</tr>

<tr>
<td width=75 id='desc' valign=top>
Default Repeat Count
</td>
<td>
<INPUT TYPE=text NAME=defaultcnt VALUE="{$defaultcnt}" SIZE=4 MAXLENGTH=4><BR>
Default repeat count for newly added public messages, 0 = Infinite
</td>
</tr>

<tr>
<td width=75 id='desc' valign=top>
Default Dwell Time
</td>
<td>
<INPUT TYPE=text NAME=defaultdwell VALUE="{$defaultdwell}" SIZE=4 MAXLENGTH=4><BR>
Default Dwell Time for newly added public messages
</td>
</tr>

<tr>
<td width=75 id='desc' valign=top>
Block Messages 
</td>
<td>
{$blockgroup}
</td>
</tr>


<tr>
<td width=75 id='desc' valign=top>
Static Message
</td>
<td>
<TEXTAREA ROWS=5 COLS=32 WRAP=SOFT NAME="staticmsg">
{$staticmsg}</textarea>

</td>
</tr>
<TR><td id='desc'>Justify: </td><td>{$st_justifygroup}</td><tr>
<TR><td id='desc'> Word Wrap: </td><td>{$st_wordwraphtml} </td></tr>
<TR><td id='desc'> Wipe? </td><td>{$st_wipehtml}</td></tr>
<tr>
<td id="desc">
&nbsp;
</td>
<td>
<input type=submit name="Commit" value="Commit Changes">
<input type=submit name="CommitBackup" value="Commit Changes and Backup">
</td>
</tr>
</table>

</p>
<!-- %%BOTTOM_END%% -->
   </DIV>
  </DIV>
 </BODY>
</HTML>
