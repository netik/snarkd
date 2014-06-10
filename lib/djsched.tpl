<BODY BGCOLOR="#000000" TEXT="#00FF00"
      LINK="#00DDFF" VLINK="#AADD00" ALINK="#FF6633">
<!-- message form -->
<INPUT TYPE=HIDDEN NAME=msgid VALUE={$msgid}>

<font size=+2>{$status}</font>
<P>

<div id=header>S N A R K - A - T R O N : DJ Schedule Entry</div>
</p>

<!--<div id=specials><font color=#aaaaaa>Message specials:</font> \n Newline | %%C Clear to EOL | <font color=#ff0000>%%R Red</font> | <font color=#00ff00>%%G Green</font> | <font color='#FFF833'>%%A Amber</font> | %%X solid block | %%B Flash On | %%E Flash off</div> -->
<P>
 Jump to:
	 <a href="/sign/admin/index.cgi">SnarkAdmin</a> |
	 <a href="/sign/dj/djadd.cgi">DJ Song/Title Entry</a> |
	 <a href="/sign/index.cgi">Public Message Entry</a> 
</p>
<CENTER><TABLE WIDTH=100%>
<TABLE>
<TR>
  <TD COLSPAN=2>Display Title: <input type=text name=title maxlength=32 size=32 value="{$title}"></TD>
</TR>
<TR>
  <TD><B>Time</B></TD>
  <TD><B>DJ Name / Act</B></TD>
</TR>

<TR>
  <TD><input type=text name=time1 maxlength=8 size=8 value="{$time[1]}"></TD>
  <TD><input type=text name=djname1 maxlength=15 size=15 value="{$djname[1]}"></TD>
</TR>
<TR>
  <TD><input type=text name=time2 maxlength=8 size=8 value="{$time[2]}"></TD>
  <TD><input type=text name=djname2 maxlength=15 size=15 value="{$djname[2]}"></TD>
</TR>
<TR>
  <TD><input type=text name=time3 maxlength=8 size=8 value="{$time[3]}"></TD>
  <TD><input type=text name=djname3 maxlength=15 size=15 value="{$djname[3]}"></TD>
</TR>
<TR>
  <TD><input type=text name=time4 maxlength=8 size=8 value="{$time[4]}"></TD>
  <TD><input type=text name=djname4 maxlength=15 size=15 value="{$djname[4]}"></TD>
</TR>
<TR>
  <TD><input type=text name=time5  maxlength=8 size=8 value="{$time[5]}"></TD>
  <TD><input type=text name=djname5  maxlength=15 size=15 value="{$djname[5]}"></TD>
</TR>
<TR>
  <TD><input type=text name=time6 maxlength=8 size=8 value="{$time[6]}"></TD>
  <TD><input type=text name=djname6 maxlength=15 size=15 value="{$djname[6]}"></TD>
</TR>
</TABLE>
</TABLE>


<TABLE WIDTH=100>
<TR>
<TD>
<input name="Save" type=submit value="Save">
</TD>
<TD>
<input name="Remove" type=submit value="Remove">
</TD>
</TR>
</TABLE>


</center>
