 <BODY BGCOLOR="#000000" TEXT="#00FF00"
       LINK="#00DDFF" VLINK="#AADD00" ALINK="#FF6633">
<!-- message form -->
<INPUT TYPE=HIDDEN NAME=msgid VALUE={$msgid}>

<center><font size=+2>{$status}</font></center>
<P>
<div id=header>S N A R K - A - T R O N : DJ Song Entry</div>
</p>

<!--<div id=specials><font color=#aaaaaa>Message specials:</font> \n Newline | %%C Clear to EOL | <font color=#ff0000>%%R Red</font> | <font color=#00ff00>%%G Green</font> | <font color='#FFF833'>%%A Amber</font> | %%X solid block | %%B Flash On | %%E Flash off</div> -->

<P>
 Jump to:
	 <a href="/sign/admin/index.cgi">SnarkAdmin</a> |
	 <a href="/sign/dj/djsched.cgi">DJ Schedule Entry</a> |
	 <a href="/sign/index.cgi">Public Message Entry</a> 
</p>
<P>
<B>DJ Name:</B><BR>
<input type=text name=djname maxlength=50 size=100 value={$djname}>
</p>

<B>Artist:</B><BR>
<input type=text name=band maxlength=100 size=100>

</p>

<P>
<B>Song Title:</B><BR>
<input type=text name=sngtitle maxlength=100 size=100>
</p>
<TABLE width=100%>
<TR>
<TD>
<input name="Add" type=submit value="Add">
</TD>
<TD>
<input name="Remove" type=submit value="Remove">
</TD>
<TD>
<input name="Clear" type=submit value="Clear Setlist">
</TD>
</TABLE>
<P>

{$setlist}


